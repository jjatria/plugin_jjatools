# Praat object to JSON converter
# This version is _much_ simpler, and _much_ more robust but it does require
# Perl. For the older, kludgier, pure praat version, use save_as_json.old.praat
#
# Written by Jose J. Atria (13 February 2015)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/utils.proc
include ../procedures/selection.proc
include ../procedures/check_filename.proc

form Save as YAML...
  sentence Save_as
  optionmenu Format: 1
    option Data stream
    option Collection

  comment This command requires PERL
  comment If saving multiple objects with the same name, save as Collection
endform

runScript: "../../plugin_jjatools/management/serialise_to_text.praat",
  ... save_as$, "YAML", format$, 0
