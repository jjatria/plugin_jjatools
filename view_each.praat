# View each selected Sound (and TextGrid) object in turn
#
# The script allows for easy navigation between selected Sound
# objects, which is particularly useful when comparing specific
# features in each of them. If an equal number of TextGrid and
# Sound objects have been selected, they will be paired by name
# and viewed in unison.
#
# Written by Jose J. Atria (October 14, 2012)
# Last revision: April 4, 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include require.proc
@require("5.3.44")

total_sounds    = numberOfSelected("Sound")
total_textgrids = numberOfSelected("TextGrid")

if total_textgrids and total_textgrids != total_sounds
	exitScript("Different number of Sounds and TextGrids selected")
endif

for i to total_sounds
	sound[i] = selected("Sound", i)
	if total_textgrids
		textgrid[i] = selected("TextGrid", i)
	endif
endfor

for i to total_sounds
	selectObject(sound[i])
	name$ = selected$("Sound")
	if total_textgrids
		plusObject(textgrid[i])
	endif

	View & Edit

	beginPause("Viewing " + name$)

	if i > 1
		button = endPause("Stop", "Previous", if i = total_sounds then "Finish" else "Next" fi, 3, 1)
	else
		button = endPause("Stop", if i = total_sounds then "Finish" else "Next" fi, 2, 1)  
	endif

	editor_name$ = if total_textgrids then "TextGrid " else "Sound " fi + name$
	nocheck editor 'editor_name$'
		nocheck Close
	nocheck endeditor

	if button = 1
		@endScript()
	elsif button = 2 and i > 1
		i -= 2
	endif
endfor

procedure endScript ()
	if total_sounds
		# Clear selection
		nocheck selectObject(undefined)
		# Recover original selection
		for i to total_sounds
			plusObject(sound[i])
			if total_textgrids
				plusObject(textgrid[i])
			endif
		endfor
	endif
endproc
