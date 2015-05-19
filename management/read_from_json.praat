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

include ../../plugin_utils/procedures/utils.proc
include ../../plugin_utils/procedures/check_filename.proc
include ../../plugin_selection/procedures/selection.proc

form Read from serialised text file...
  sentence Read_from
  comment This command reads from YAML or JSON files
  comment File format will be detected from file extension
endform

@checkFilename(read_from$, "Read serialised text file...")
infile$ = checkFilename.name$

name$ = right$(infile$, length(infile$) - rindex(infile$, "/"))
type$ = right$(infile$, length(infile$) - rindex(infile$, "."))
name$ = name$ - ("." + type$)

# Create temporary directory for output
@mktemp: "readserial.XXXXX"
tmpfile$ = mktemp.name$ + name$ + ".Praat"

command$ = "perl " +
  ... preferencesDirectory$ + "/plugin_serialise/scripts/yaml2praat.pl " +
  ... infile$ + " --outfile " + tmpfile$
# appendInfoLine: command$
system_nocheck 'command$'

nocheck Read from file: tmpfile$

deleteFile: tmpfile$
deleteFile: mktemp.name$
