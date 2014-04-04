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

form Save selected objects to JSON...
	sentence Save_to
	comment Leave blank for GUI selector
	optionmenu Format: 1
		option Pretty printed
		option Minified
endform

n = numberOfSelected()

if n
	@checkDirectory(save_to$, "Save to...")
	path$ = checkDirectory.name$

	runScript: "save_as_json.praat", path$, format$
endif
