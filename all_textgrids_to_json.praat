# Convert TextGrids to JSON
# Written by Jose Joaquin Atria (31 March 2014)
#
# Converts all TextGrid objects in the specified directory
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

form TextGrids in directory to JSON...
  sentence TextGrid_directory
  comment Leave blank for GUI selector
  optionmenu Format: 1
    option Pretty printed
    option Minified
endform

@checkDirectory(textGrid_directory$, "TextGrid directory...")
path$ = checkDirectory.name$

files = Create Strings as file list: "files", path$ + "*TextGrid"

n = Get number of strings
for i to n
	selectObject(files)
	filename$ = Get string: i
	textgrid = Read from file: path$ + filename$
	runScript: "textgrid_to_json.praat", path$, format$
	removeObject(textgrid)
endfor
removeObject(files)
