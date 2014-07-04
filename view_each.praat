# View each selected Sound (and TextGrid) object in turn
#
# The script allows for easy navigation between selected Sound
# objects, which is particularly useful when comparing specific
# features in each of them. If an equal number of TextGrid and
# Sound objects have been selected, they will be paired by name
# and viewed in unison.
#
# Written by Jose J. Atria (October 14, 2012)
# Last revision: July 2, 2014)
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
include selection_tools.proc

# Generate a table with object types and number of selected
# objects of each type
@checkSelection()
object_table = checkSelection.object_table
selection_table = checkSelection.raw_table

n = numberOfSelected()

## Paired object types
selectObject: object_table

# Sound + TextGrid
@countObjects(object_table, "Sound")
sounds    = countObjects.n

@countObjects(object_table, "TextGrid")
textgrids = countObjects.n

if sounds = textgrids
  selectObject: selection_table
  textgrid_table = Extract rows where column (text): "type", "is equal to", "TextGrid"
endif

for i to n
  pair = 0
  # We use the selection table to iterate through the selection
  selectObject: selection_table
  id = Get value: i, "id"
  
  # id might be flagged to negative, if we are to skip that object
  # (in case it has been paired)
  if id > 0
    selectObject: id

    type$ = extractWord$(selected$(), "")
    name$ = selected$(type$)
    
    if type$ = "Sound"
      # If current object is a Sound
      if sounds = textgrids
        # and an equal number of Sounds and TextGrids
        # are selected, they might be paired, so we check
        sound_duration = Get total duration
        
        # We check the corresponding TextGrid by number from the selection
        selectObject: textgrid_table
        pair = Get value: i, "id"
        
        selectObject: pair
        textgrid_duration = Get total duration
        
        # If durations match, they are likely paired
        if sound_duration = textgrid_duration
          # and we set a flag on that object's id if it has been paired
          selectObject: selection_table
          pair_row = Search column: "id", string$(pair)
          Set numeric value: pair_row, "id", pair * -1
          
          # Since they match, we select both
          selectObject: id, pair
        else
          # Objects do not match
        endif
      endif
    endif

    View & Edit

    beginPause("Viewing " + name$)

    if i > 1
      button = endPause("Stop", "Previous", if i = n then "Finish" else "Next" fi, 3, 1)
    else
      button = endPause("Stop", if i = n then "Finish" else "Next" fi, 2, 1)  
    endif

    editor_name$ = if textgrids then "TextGrid " else "Sound " fi + name$
    nocheck editor 'editor_name$'
      nocheck Close
    nocheck endeditor

    if button = 1
      # Pressed stop
      @endScript()
    elsif button = 2 and i > 1
      # Pressed back
      if pair
#        printline reverting flag
        # If we are paired we need to unset the "skip" flag on the pair
        selectObject: selection_table
        pair_row = Search column: "id", string$(pair * -1)
        Set numeric value: pair_row, "id", pair
      else
#        printline No pair
      endif
      
      i -= 2
      
    endif
    
  endif
endfor

procedure endScript ()
  @restoreLastSelection()
endproc
