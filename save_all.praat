# Save all selected objects to disk. By default, the script overwrites
# existing files and prints the number of saved objects to the Info
# screen. This behaviour can be changed by modifying the overwrite and
# verbose variables respectively.
# 
# The first version of this script was written for the
# Laboratorio de Fonetica Letras UC
#
# Written by Jose J. Atria (18 November 2011)
# Complete re-write: February 27, 2014
#
# This script is free software: you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include check_directory.proc

form Save selected objects...
	sentence Save_to
	comment Leave empty for GUI selector
	sentence Pad_name_with _
	comment Name padding used to create unique names
	boolean Overwrite no
	boolean Quiet yes
endform

if praatVersion < 5363
	exitScript("This script has been written using the new syntax,
		...not available for the version you are using.", newline$,
		..."Please upgrade to 5.3.63 or higher.", newline$)
endif

verbose = if quiet then 0 else 1 fi
cleared_info = 0

@checkDirectory(save_to$, "Save objects to...")
directory$ = checkDirectory.name$

# Save selection
selected_objects = numberOfSelected()
for i to selected_objects
	my_object[i] = selected(i)
endfor

# Create Table to store object data
object_data = Create Table with column names: "objects", selected_objects,
	..."id type name extension num"

# Populate Table with data
for i to selected_objects
	selectObject(my_object[i])
	type$ = extractWord$(selected$(), "")
	name$ = selected$(type$)

	if type$ = "Sound"
		extension$ = ".wav"
	elsif type$ != "LongSound"
		extension$ = "." + type$
	endif
		
	selectObject(object_data)
	Set numeric value: i, "id",        my_object[i]
	Set string value:  i, "type",      type$
	Set string value:  i, "name",      name$
	Set string value:  i, "extension", extension$
	Set numeric value: i, "num",       number(name$)
endfor

# Sort Table rows, 
Sort rows: "num name"

# create name conversion table
conversion_table = Collapse rows: "name type", "", "", "", "", ""
Append column: "new_name"

if !overwrite
	n = Get number of rows
	for i to n
		name$ = Get value: i, "name"
		type$ = Get value: i, "type"

		pad$ = ""
		repeat
			file_name$ = name$ + pad$ + extension$
			full_name$ = directory$ + "/" + file_name$
			
			pad$ = pad$ + pad_name_with$
			new_name$ = file_name$ - extension$
			converted = Search column: "new_name", new_name$
		until !(fileReadable(full_name$) or converted)

		if name$ != new_name$
			Set string value: i, "new_name", new_name$
		else
			Set string value: i, "name", ""
		endif
	endfor
endif

# Create saved names hash
used_names = Create Table with column names: "used_names", 0, "name n"

saved_files = 0

# Loop through objects, for saving
for i to selected_objects
	selectObject(object_data)
	id         = Get value: i, "id"
	type$      = Get value: i, "type"
	name$      = Get value: i, "name"
	extension$ = Get value: i, "extension"

	if !overwrite
		selectObject(conversion_table)
		converted = Search column: "name", name$
		if converted
			converted_name$ = Get value: converted, "new_name"
			name$ = converted_name$
		endif
	endif
		
	selectObject(used_names)
	used = Search column: "name", name$
	counter = 0
	if used
		counter = Get value: used, "n"
		Set numeric value: used, "n", counter+1
	else
		Append row
		r = Get number of rows
		Set numeric value: r, "n", 1
		Set string value: r, "name", name$
	endif

	counter$ = string$(counter)
	counter$ = if counter$ = "0" then "" else counter$ fi

	selectObject(id)

	file_name$ = name$ + counter$ + extension$
	full_name$ = directory$ + "/" + file_name$
	if type$ = "Sound"
		Save as WAV file: full_name$
	elsif type$ != "LongSound"
		Save as text file: full_name$
	endif

	if verbose
		if !cleared_info
			clearinfo
			cleared_info = 1
		endif
		appendInfoLine("Saved ", selected$(type$), " as ", full_name$)
	endif
	
endfor

removeObject(object_data, conversion_table, used_names)

if selected_objects
	selectObject(my_object[1])
	for i from 2 to selected_objects
		plusObject(my_object[i])
	endfor
endif