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

form Save as serialised text file...
  sentence Save_to
  optionmenu Output: 1
    option JSON
    option YAML
  optionmenu Save_as: 1
    option Data stream
    option Collection
  boolean Pretty_printed yes

  comment This command requires PERL
  comment If saving multiple objects with the same name, save as Collection
endform

# Save original selection
@saveSelection()
@saveSelectionTable()
original_selection = saveSelectionTable.table

# De-select all incompatible objects
@deselect_unsupported(original_selection)

# Set initial options:
# Should output be pretty-printed?
@tolower(output$)
output$ = tolower.return$
format$ = if pretty_printed then "pretty" else "minified" fi
# Should output maintain Collection structure?
collection = if save_as$ = "Collection" then 1 else 0 fi

# Prepare for writing
# Generate filename for Praat serialisation
if numberOfSelected() = 1
  type$ = extractWord$(selected$(), "")
  name$ = selected$(type$)
  infile$ = name$ + "." + type$

  # Generate output filename
  @tolower(type$)
  outfile$ = name$ + "_" + tolower.return$ + "." + output$
else
  infile$  = "praat_collection.Collection"
  outfile$ = "praat_collection." + output$
endif

# Set output file
@checkWriteFile(save_to$,
  ... "Save object(s) as one " + output$ + " file...", outfile$)
outfile$ = checkWriteFile.name$

# Create temporary directory for output
@mktemp: ""
infile$ = mktemp.name$ + infile$

# Do it!
@serialise(infile$, outfile$, output$, format$, "write", collection)

# Delete the temporary directory
deleteFile: mktemp.name$

# Restore the original selection and clean-up
@selectSelectionTables()
Remove
@restoreSelection

#
# Procedures
#

# Serialise the data structure, with the help of a Perl script
procedure serialise (.in$, .out$, .output$, .format$, .mode$)
  Save as text file: .in$
  command$ = "perl " +
    ... preferencesDirectory$ + "/plugin_jjatools/helper/praat2yaml.pl " +
    ... "--" + .output$ + " " +
    ... "--" + .format$ + " " + .in$ +
    ... " > " + .out$
#   appendInfoLine: command$
  system 'command$'
  deleteFile: .in$
endproc

# Deselect unsupported objects
procedure deselect_unsupported (.selection)
  .unsupported$ = "LongSound Photo"
  @split: " ", .unsupported$

  @createEmptySelectionTable()
  .unsupported = createEmptySelectionTable.table

  .warnings = 0

  for .i to split.length
    @restoreSavedSelection(.selection)
    @refineToType(split.return$[.i])

    if numberOfSelected()
      .warnings = 1
      appendInfoLine: "W: ", split.return$[.i], " objects not supported"
    endif

    @plusSavedSelection(.unsupported)
    @saveSelectionTable()
    removeObject: .unsupported
    .unsupported = saveSelectionTable.table
  endfor

  if .warnings
    beginPause: "Some unsupported objects were deselected. Do you want to continue?"
    .button = endPause: "Yes", "No", 2, 2
    if .button = 2
      removeObject: .unsupported
      @restoreSavedSelection(.selection)
      exit
    endif
  endif

  @restoreSavedSelection(.selection)
  @minusSavedSelection(.unsupported)
  removeObject: .unsupported
endproc
