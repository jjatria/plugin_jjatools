# TextGrid to JSON converter
#
# Written by Jose J. Atria (27 February 2014)
# Version 0.1
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include check_directory.proc
include json.proc

form Save as JSON...
	sentence Save_to
	optionmenu Format: 1
		option Pretty printed
		option Minified
endform

@checkDirectory(save_to$, "Save JSON to...")
directory$ = checkDirectory.name$

total_objects = numberOfSelected()

for i to total_objects
	myobj[i] = selected(i)
endfor

if format$ = "Pretty printed"
	n$ = newline$
	t$ = tab$
	s$ = " "
elsif format$ = "Minified"
	n$ = ""
	t$ = n$
	s$ = n$
endif

for i to total_objects
	selectObject(myobj[i])
	type$ = extractWord$(selected$(), "")
	name$ = selected$(type$)
	start = Get start time
	end = Get end time
	output_file$ = directory$ + "/" + name$ + ".json"

  if type$ = "TextGrid"
		json_type$ = "textgrid"
	elsif type$ = "PointProcess"
		json_type$ = "points"
	elsif type$ = "PitchTier" or
		... type$ = "DurationTier"
		json_type$ = "points_with_numbers"
	else
		json_type$ = "unsupported"
	endif
	
	if json_type$ != "unsupported"
		if fileReadable(output_file$)
			deleteFile: output_file$
		endif
		
		@startJsonObject(output_file$)
		@writeJsonString(output_file$, "File type", "json", 0)
		@writeJsonString(output_file$, "Object class", type$, 0)
		@writeJsonNumber(output_file$, "start", start, 0)
		@writeJsonNumber(output_file$, "end", end, 0)

		if json_type$ = "textgrid"

			@startJsonList(output_file$, "tiers")

			tiers = Get number of tiers
			for t to tiers
				last = if t = tiers then 1 else 0 fi
				@writeJsonTgTier(output_file$, t, last)
			endfor
			
			@endJsonList(output_file$, 1)

		elsif left$(json_type$, 6) = "points"
		
			points = Get number of points
			list_name$ = "points"
			
			if points
			
				# Hack for DurationTier objects
				if type$ = "DurationTier"
					dtfull = Copy: "full"
					dtblank = Copy: "blank"
				endif
				for p to points
					time = Get time from index: p
					selectObject(dtblank)
					Remove point: p
					Add point: p, 1
					selectObject(myobj[i])
				endfor
				# End of hack
			
				@startJsonList(output_file$, list_name$)
				
				for p to points
					last = if p = points then 1 else 0 fi
					time = Get time from index: p
					if json_type$ = "points_with_numbers"
						if type$ = "PitchTier"
							value = Get value at index: p
						elsif type$ = "DurationTier"
						
							# Hack for DurationTier objects
							selectObject(dtfull)
							new_duration = Get target duration: 0, time
							Remove point: 1
							selectObject(dtblank)
							old_duration = Get target duration: 0, time
							value = new_duration / old_duration
							Remove point: 1
							selectObject(myobj[i])
							# End of hack
							
						endif
						@writeJsonPointWithNumber(output_file$, time, value, last)
					elsif json_type$ = "points"
						@pushToJsonList(output_file$, time, last) 
					endif
				endfor
				
				# Hack for DurationTier objects
				removeObject(dtfull)
				removeObject(dtblank)
				selectObject(myobj[i])
				# End of hack
				
				@endJsonList(output_file$, 1)
				
			else
			
				@writeJsonEmptyList(output_file$, list_name$, 1)
				
			endif
		else
			writeInfoLine(left$(json_type$, 6))
		endif

		@endJsonObject(output_file$, 1)
	else
		appendInfoLine("JSON: ", type$, " not yet supported")
	endif
endfor

if total_objects
	selectObject(myobj[1])
	for i from 2 to total_objects
		plusObject(myobj[i])
	endfor
endif
