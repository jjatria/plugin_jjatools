# View each selected Sound (and TextGrid) object in turn
#
# The script allows for easy navigation between selected Sound
# objects, which is particularly useful when comparing specific
# features in each of them. If an equal number of TextGrid and
# Sound objects have been selected, they will be paired by name
# and viewed in unison.
#
# Written by Jose J. Atria (October 14, 2012)
# Last revision: July 10, 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/require.proc
@require("5.3.44")
include ../procedures/selection.proc

# Generate a table with object types and number of selected
# objects of each type
@saveSelectionTable()
selection = saveSelectionTable.table
selectObject: selection
Rename: "original"
@restoreSavedSelection(selection)

@checkSelection()
object_table = checkSelection.table
selectObject: object_table
Rename: "objects"
@restoreSavedSelection(selection)

n = numberOfSelected()

## Paired object types
selectObject: object_table

# Check if Sound and TextGrid objects are the only types
# and if they are in the same number, for pairing.
paired = 0
total_types = Get number of rows
if total_types = 2
  @countObjects(object_table, "Sound")
  sounds    = countObjects.n
  @countObjects(object_table, "TextGrid")
  textgrids = countObjects.n
  if sounds = textgrids
    paired = 1
    @restoreSavedSelection(selection)
    @refineToType("Sound")
    @saveSelectionTable()
    sounds = saveSelectionTable.table
    selectObject: sounds
    Rename: "sounds"

    @restoreSavedSelection(selection)
    @refineToType("TextGrid")
    @saveSelectionTable()
    textgrids = saveSelectionTable.table
    selectObject: textgrids
    Rename: "textgrids"

    selectObject: sounds
    n = Get number of rows
  endif
endif

# No more use for object type table
removeObject: object_table

if paired
  base_selection = sounds
  pair_selection = textgrids
else
  base_selection = selection
endif

i = 1
while i <= n
  # We use the selection table to iterate through the selection
  selectObject: base_selection
  base       = Get value: i, "id"
  base_type$ = Get value: i, "type"
  base_name$ = Get value: i, "name"

  if paired
    selectObject: pair_selection
    pair       = Get value: i, "id"
    pair_type$ = Get value: i, "type"
    pair_name$ = Get value: i, "name"
  endif
  selectObject: base
  if paired
    plusObject: pair
  endif

  if base_type$ = "LongSound"
    View
  else
    View & Edit
  endif

  beginPause: "Viewing " + base_name$
    ... + " (" + string$(i) + " of " + string$(n) + ")"

  if i > 1
    button = endPause: "Stop", "Previous", if i = n then "Finish" else "Next" fi, 3, 1
  else
    button = endPause: "Stop", if i = n then "Finish" else "Next" fi, 2, 1
  endif

  # If objects are renamed while viewing each, editors are
  # not closed properly. Attempted to solve
  # this, but it didn't work. Why?

  if paired
    selectObject: pair
    editor_name$ = pair_type$ + " " + selected$(pair_type$)
  else
    editor_name$ = base_type$ + " " + selected$(base_type$)
  endif

#   appendInfoLine: "Tried closing ", editor_name$

  nocheck editor 'editor_name$'
    nocheck Close
  nocheck endeditor

  if button = 1
    # Pressed stop
    @endScript()
  elsif button = 2 and i > 1
    # Pressed back
    i -= 1
  else
    if i = n
      @endScript()
    else
      i += 1
    endif
  endif
endwhile

procedure endScript ()
  @restoreSavedSelection(selection)
  removeObject: selection
  if paired
    removeObject: base_selection, pair_selection
  endif
  exitScript()
endproc
