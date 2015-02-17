# Restores a selection from the current selection table
#
# Written by Jose J. Atria
# Last revision: 17 February 2015
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

jja.restore_nocheck = 1
include ../procedures/selection.proc

if numberOfSelected("Table") != numberOfSelected()
  exit "Please select only selection tables"
endif

table = Append
@restoreSavedSelection(table)
removeObject: table
