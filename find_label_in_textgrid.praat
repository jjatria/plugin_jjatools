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

form Find label...
  word Label
  integer Index
  integer Tier 1
endform

counter = 0
n = Get number of intervals: tier
for i to n
  lab$ = Get label of interval: tier, i
  if lab$ = label$
    counter += 1
    if index and counter = index
      printline 'i'
    endif
  endif
endfor