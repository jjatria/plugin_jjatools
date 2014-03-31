# View each selected Sound object in turn.
#
# The script allows for easy navigation between selected Sound
# objects, which is particularly useful when comparing specific
# features in each of them.
#
# Written by Jose J. Atria (October 14, 2012)
# Last revision: February 20, 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

n_sound    = numberOfSelected("Sound")
n_textgrid = numberOfSelected("TextGrid")

if n_textgrid and n_textgrid != n_sound
  exitScript("Different number of Sounds and TextGrids selected")
endif

for i to n_sound
  sound[i] = selected("Sound", i)
  if n_textgrid
    textgrid[i] = selected("TextGrid", i)
  endif
endfor

for i to n_sound
  selectObject(sound[i])
  name$ = selected$("Sound")
  if n_textgrid
    plusObject(textgrid[i])
  endif
  
  View & Edit
  
  beginPause("Viewing " + name$)
  
  if i > 1
    button = endPause("Stop", "Previous", if i = n_sound then "Finish" else "Next" fi, 3, 1)
  else
    button = endPause("Stop", if i = n_sound then "Finish" else "Next" fi, 2, 1)  
  endif
  
  editor_name$ = if n_textgrid then "TextGrid " else "Sound " fi + name$
  nocheck editor 'editor_name$'
    nocheck Close
  nocheck endeditor
 
  if button = 1
    goto END
  elsif button = 2 and i > 1
    i -= 2
  endif
endfor

label END
if n_sound
  selectObject(sound[1])
  if n_textgrid
    plusObject(textgrid[1])
  endif
  for i from 2 to n_sound
    plusObject(sound[i])
    if n_textgrid
      plusObject(textgrid[i])
    endif
  endfor
endif