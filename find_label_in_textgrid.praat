# Find label in a TextGrid Interval tier.
#
# The script runs through the intervals of an interval tier looking
# for a literal label. If found, it prints the number of the interval
# that holds it. Using the value in the "index" variable it's possible
# to look for the interval number with the nth repetition of the label.
# 
# The first version of this script was written for the
# Laboratorio de Fonetica Letras UC
#
# Written by Jose J. Atria (18 November 2011)
# Latest revision: April 4, 2014
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
	integer Index 1
	integer Tier 1
endform

target_label$ = label$

# Require one TextGrid object
textgrid = numberOfSelected("TextGrid")
if textgrid = 1

	interval_tier = Is interval tier... tier
	if interval_tier
		counter = 0

		n = Get number of intervals... tier
		for i to n
			label$ = Get label of interval: tier, i
			if label$ = target_label$
				counter += 1
				if index and counter = index
					printline 'i'
					i = n
				endif
			endif
		endfor
	else
		exit Tier 'tier' is not an interval tier
	endif
else
	exit Please select a single TextGrid object.'newline$'
endif