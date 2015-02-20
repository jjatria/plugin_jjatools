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

form Read from serialised text file...
  sentence Read_from
  comment This command reads from YAML or JSON files
  comment File format will be detected from file extension
endform

@checkFilename(read_from$, "Read serialised text file...")
infile$ = checkFilename.name$

name$ = right$(infile$, length(infile$) - rindex(infile$, "/"))
type$ = right$(infile$, length(infile$) - rindex(infile$, "."))
type$ = if type$ = "json" or type$ = "yaml" then type$ else "yaml" fi 
name$ = name$ - ("." + type$)

# Create temporary directory for output
@mktemp: "readserial.XXXXX"
tmpfile$ = mktemp.name$ + name$ + ".Praat"

command$ = "perl " +
  ... preferencesDirectory$ + "/plugin_jjatools/helper/yaml2praat.pl " +
  ... "--" + type$ + " " +
  ... infile$ + " > " + tmpfile$
# appendInfoLine: command$
system_nocheck 'command$'

Read from file: tmpfile$

deleteFile: tmpfile$
deleteFile: mktemp.name$
