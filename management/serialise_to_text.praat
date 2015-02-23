# Praat object serialiser
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

form Save as serialised text file...
  sentence Save_as
  optionmenu Output: 1
    option JSON
    option YAML
  optionmenu Format: 1
    option Data stream
    option Collection
  boolean Pretty_printed yes

  comment This command requires PERL
  comment If saving multiple objects with the same name, save as Collection
endform

# Save original selection
@saveSelectionTable()
original_selection = saveSelectionTable.table

# De-select all incompatible objects
@deselectTypes("LongSound")

# Set initial options:
# Should output be pretty-printed?
@toLower(output$)
output$ = toLower.return$
format$ = if pretty_printed then "pretty" else "minified" fi
# Should output maintain Collection structure?
collection = if format$ = "Collection" then 1 else 0 fi

# Prepare for writing
# Generate filename for Praat serialisation
if numberOfSelected() = 1
  type$ = extractWord$(selected$(), "")
  name$ = selected$(type$)
  infile$ = name$ + "." + type$

  # Generate output filename
  @toLower(type$)
  outfile$ = name$ + "_" + toLower.return$ + "." + output$
else
  infile$  = "praat_collection.Collection"
  outfile$ = "praat_collection." + output$
endif

# Set output file
@checkWriteFile(save_as$,
  ... "Save object(s) as one " + output$ + " file...", outfile$)
outfile$ = checkWriteFile.name$

# Create temporary directory for output
@mktemp: "toserial.XXXXX"
infile$ = mktemp.name$ + infile$

# Do it!
@serialise(infile$, outfile$, output$, format$, collection)

# Delete the temporary directory
deleteFile: mktemp.name$

# Restore the original selection and clean-up
@restoreSavedSelection(original_selection)
removeObject: original_selection

#
# Procedures
#

# Serialise the data structure, with the help of a Perl script
procedure serialise (.in$, .out$, .output$, .format$, collection)
  Save as text file: .in$
  command$ = "perl " +
    ... preferencesDirectory$ + "/plugin_jjatools/helper/praat2yaml.pl " +
    ... "--" + .output$ + " " +
    ... "--" + .format$ + " " + .in$ +
    ... " > " + .out$
#   appendInfoLine: command$
  system_nocheck 'command$'
  deleteFile: .in$
endproc
