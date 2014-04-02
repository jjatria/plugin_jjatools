# Batch JSON converter
# Written by Jose Joaquin Atria (31 March 2014)
#
# Converts all supported objects in the specified directory
# to JSON formatted files.
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include check_directory.proc

form Batch convert to JSON...
	sentence Directory
	optionmenu Convert: 1
		option TextGrid
		option DurationTier
		option PitchTier
	comment Leave blank for GUI selector
	optionmenu Format: 1
		option Pretty printed
		option Minified
endform

@checkDirectory(directory$, "Read objects from...")
path$ = checkDirectory.name$

files = Create Strings as file list: "files", path$ + "*" + convert$

n = Get number of strings
for i to n
	selectObject(files)
	filename$ = Get string: i
	myobject = Read from file: path$ + filename$
	runScript: "save_as_json.praat", path$, format$
	removeObject(myobject)
endfor
removeObject(files)
