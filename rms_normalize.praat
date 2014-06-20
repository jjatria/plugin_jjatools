# Normalise all sounds in a given directory using RMS normallisation
# 
# Written by Jose J. Atria (29 May 2014)
#
# This script is free software: you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.
#
# TODO: set sounds to specified RMS

include require.proc
@require("5.3.63")

form RMS normalisation...
  positive Peak_to 0.9
  boolean Keep_conversion_table no
  boolean Make_changes_inline no
endform

stopwatch

n = numberOfSelected("Sound")
for i to n
  sound[i] = selected("Sound", i)
endfor

mindb = 70

if n
  table = Create Table with column names: "conversions", 0,
    ..."name rms_pre max_pre rms_post max_post"

  for i to n
    sound = sound[i]
    selectObject(sound)
    name$ = selected$("Sound")

    @rms_and_max()

    selectObject(table)
    Append row
    Set string value:  i, "name",    name$
    Set numeric value: i, "rms_pre", rms
    Set numeric value: i, "max_pre", max
    
    selectObject(sound)
    if !make_changes_inline
      norm[i] = Copy: name$ + "_normalised"
    else
      norm[i] = sound
    endif
    
    Scale intensity: mindb

    @rms_and_max()

    selectObject(table)
    Set numeric value: i, "rms_post", rms
    Set numeric value: i, "max_post", max
  endfor

  selectObject(table)
  max = Get maximum: "max_post"
  factor = peak_to / max

  for i to n
    selectObject(norm[i])
    name$ = selected$("Sound")
    
    Formula: "self*" + string$(factor)
    
    @rms_and_max()
    
    selectObject(table)
    Set numeric value: i, "rms_post",  rms
    Set numeric value: i, "max_post",  max
    
    selectObject(norm[i])
  endfor

  if !keep_conversion_table
    removeObject(table)
  endif

  time = stopwatch

  writeInfoLine: "Processed " + string$(n) + " files in " + fixed$(time, 2) + " seconds"
  appendInfoLine: "All processed files set to a RMS of " + fixed$(rms, 2) + " Pascal"
endif

procedure rms_and_max ()
  rms = Get root-mean-square: 0, 0
  max = Get maximum: 0, 0, "None"
  min = Get minimum: 0, 0, "None"
  max = if abs(max) > abs(min) then abs(max) else abs(min) fi
endproc