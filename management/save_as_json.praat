# Praat object to JSON converter
# This version is _much_ simpler, and _much_ more robust but it does require
# Perl. For the older, kludgier, pure praat version, use save_as_json.old.praat
#
# Written by Jose J. Atria (10 February 2015)
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
include ../procedures/check_directory.proc

form Save as serialised text file...
  sentence Save_to
  optionmenu Output: 1
    option JSON
    option YAML
  boolean Pretty_printed yes
  
  comment This command requires PERL
endform

@saveSelection()

@tolower(output$)
output$ = tolower.return$
format$ = if pretty_printed then "pretty" else "minified" fi

@checkDirectory(save_to$, "Save to...")
directory$ = checkDirectory.name$

@mktemp: ""
tempdir$ = mktemp.name$

for i to saveSelection.n
  type$ = extractWord$(selected$(), "")

  if type$ != "Sound"
    name$ = selected$(type$)
    
    infile$ = name$ + "." + type$
    Save as text file: tempdir$ + infile$
    
    @tolower(type$)
    typename$ = tolower.return$
    outfile$ = name$ + "_" + typename$ + "." + output$
    runSystem: "perl ",
      ... preferencesDirectory$ + "/plugin_jjatools/helper/parse_praat.pl ",
      ... "--" + output$ + " ",
      ... "--" + format$ + " ", tempdir$ + infile$,
      ... " > " + directory$ + outfile$
    deleteFile: tempdir$ + infile$
  else
    appendInfoLine: "W: Sound files not supported yet"
  endif
endfor

deleteFile: tempdir$

@restoreSelection()
