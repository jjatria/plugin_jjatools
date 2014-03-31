# Filter and center sound objects
#
# The script takes a number of selected sound objects and, depending
# on user input, applies a high-pass filter to remove bands of low
# energy irrelevant for speech and/or centers the sound on zero to avoid
# oscillations that sometimes result from improper calibration of the
# recording equipment.
#
# The script will replace the selected objects with filtered objects with
# the same name.
#
# Written by Jose J. Atria (October, 2012)
# Latest revision: 21 February 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Fix selected samples...
  comment Filter options
  boolean Stop_Hann_band 1
  real left_Frequency_band 0
  real right_max_frequency 100
  boolean Subtract_mean 1
endform

minfreq = left_Frequency_band
maxfreq = right_max_frequency
fixed = 0
n = numberOfSelected("Sound")

for i to n
  sound[i] = selected("Sound", i)
endfor

for i to n
  select sound[i]
  old = selected()
  max = Get maximum: 0, 0, "Sinc70"
  min = Get minimum: 0, 0, "Sinc70"
  min *= -1
  if max(min,max)>0.99
    Remove
  else
    name$ = selected$("Sound")
    Filter (stop Hann band): minfreq, maxfreq, 100
    Subtract mean
    Rename: name$
    fixed += 1
    new[fixed] = selected()
    removeObject(old)
  endif
endfor

if fixed
  selectObject(new[1])
  for i from 2 to fixed
    plusObject(new[i])
  endfor
endif