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

include ../../plugin_jjatools/procedures/selection.proc
include ../../plugin_jjatools/procedures/check_directory.proc
include ../../plugin_jjatools/procedures/require.proc
@require("5.3.63")

form Save selected objects...
  sentence Save_to
  comment Leave empty for GUI selector
  sentence Pad_name_with _
  comment Name padding used to create unique names
  boolean Overwrite no
  boolean Verbose no
endform

cleared_info = 0

@checkDirectory(save_to$, "Save objects to...")
directory$ = checkDirectory.name$

# Save selection
@saveSelectionTable()
original = saveSelectionTable.table

selectObject: original
writable_objects = Extract rows where column (text): "type",
  ... "is not equal to", "LongSound"
Append column: "extension"
Append column: "new_name"
total_objects = Object_'writable_objects'.nrow

for row to total_objects
  extension$ = Object_'writable_objects'$[row, "type"]
  extension$ = if extension$ = "Sound" then "wav" else extension$ fi
  Set string value: row, "extension", "." + extension$
endfor

types = Collapse rows: "type", "", "", "", "", ""
total_types = Object_'types'.nrow

for t to total_types
  type_counter = 1

  selectObject: types
  type$ = Object_'type'[t, "type"]

  selectObject: writable_objects
  type_subset = Extract rows where column (text): "type",
    ... "is equal to", type$

  Sort rows: "name"

  previous_name$ = ""
  for r to Object_'type_subset'.nrow
    name$ = Object_'type_subset'$[r, "name"]
    
  endfor
endfor

# # Populate Table with data
# for i to saveSelection.n
#   selectObject(saveSelection.id[i])
#   type$ = extractWord$(selected$(), "")
#   name$ = selected$(type$)
# 
#   if type$ != "LongSound"
#     extension$ = if type$ = "Sound" then ".wav" else "." + type$ fi
# 
#     selectObject: object_data
#     Set numeric value: i, "id",        saveSelection.id[i]
#     Set string value:  i, "type",      type$
#     Set string value:  i, "name",      name$
#     Set string value:  i, "extension", extension$
#     Set numeric value: i, "num",       number(name$) ; <- What is this?
#   endif
# endfor

# # Sort Table rows,
# Sort rows: "num name"

# create name conversion table
# conversion_table = Collapse rows: "name type", "", "", "", "", ""
# Append column: "new_name"

# if !overwrite
#   n = Get number of rows
#   for i to n
#     name$ = Get value: i, "name"
#     type$ = Get value: i, "type"
# 
#     pad$ = ""
#     repeat
#       file_name$ = name$ + pad$ + extension$
#       full_name$ = directory$ + file_name$
# 
#       pad$ = pad$ + pad_name_with$
#       new_name$ = file_name$ - extension$
#       converted = Search column: "new_name", new_name$
#     until !(fileReadable(full_name$) or converted)
# 
#     if name$ != new_name$
#       Set string value: i, "new_name", new_name$
#     else
#       Set string value: i, "name", ""
#     endif
#   endfor
# endif

# # Create saved names hash
# used_names = Create Table with column names: "used_names", 0, "name n"
# 
# saved_files = 0

# Loop through objects, for saving
for i to total_objects

#   selectObject(object_data)
#   id         = Get value: i, "id"
#   type$      = Get value: i, "type"
#   name$      = Get value: i, "name"
#   extension$ = Get value: i, "extension"


# 
#   if !overwrite
#     selectObject(conversion_table)
#     converted = Search column: "name", name$
#     if converted
#       converted_name$ = Get value: converted, "new_name"
#       name$ = converted_name$
#     endif
#   endif
# 
#   selectObject(used_names)
#   used = Search column: "name", name$
#   counter = 0
#   if used
#     counter = Get value: used, "n"
#     Set numeric value: used, "n", counter+1
#   else
#     Append row
#     r = Get number of rows
#     Set numeric value: r, "n", 1
#     Set string value: r, "name", name$
#   endif
# 
#   counter$ = string$(counter)
#   counter$ = if counter$ = "0" then "" else counter$ fi
# 
#   selectObject(id)
# 
#   file_name$ = name$ + counter$ + extension$
#   full_name$ = directory$ + file_name$
# #   if type$ = "Sound"
# #     Save as WAV file: full_name$
# #   elsif type$ != "LongSound"
# #     Save as text file: full_name$
# #   endif
# 
#   if verbose
#     if !cleared_info
#       clearinfo
#       cleared_info = 1
#     endif
#     appendInfoLine("Saved ", selected$(type$), " as ", full_name$)
#   endif

endfor

#removeObject(object_data, conversion_table, used_names)

@restoreSavedSelection(original)
removeObject: original
