# Creates a Strings object which contains a subset of the strings
# of an original Strings object. Matching of strings is done through
# a regular expression.
#
# Written by Jose J. Atria (10 December 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../../plugin_jjatools/procedures/find_in_strings.proc

form Find in Strings...
  sentence Search .*
  boolean Use_regex 1
endform

@findInStrings(search$, use_regex)

writeInfoLine: findInStrings.return
