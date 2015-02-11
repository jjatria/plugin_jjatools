# Performs an inline, regex-based, "search and replace" a Strings object
# (procedure)
#
# Written by Jose J. Atria (12 December 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../../plugin_jjatools/procedures/replace_strings.proc

form Replace strings...
  sentence Find
  sentence Replace
  boolean Use_regular_expressions 1
endform

@replaceStrings(find$, replace$, use_regular_expressions)
