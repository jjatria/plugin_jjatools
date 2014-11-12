# Extract non-empty intervals from a specific tier
#
# The script will process Sound and TextGrid pairs in sequential
# order, pairing the first Sound object with the first TextGrid
# object and so on. This should be fine for most cases.
#
# If a value is specified in the "Look for" field, the script will
# only extract the sounds from intervals labeled with that string.
# If the field is empty, all non-empty intervals will be extracted.
#
# For each object pair, the script looks for the intervals on the
# specified tier and extracts them into new Sound objects. These
# objects will be renamed as 'TGNAME'_'LABEL''COUNTER'
# where TGNAME is the name of the TextGrid object, LABEL the label
# on the interval and COUNTER a number counting the occurences of
# that label so far. Thus, if there are two intervals labeled "a"
# on the specified tier, these will result in objects named
# 'TGNAME'_a1 and 'TGNAME'_a2 respectively.
#
# Since not all characters common in interval labels are acceptable
# as object names, the script makes it easy to perform systematized
# replacements on these to prevent loss of important information.
#
# These replacements can be added by inserting replace$() or
# replace_regex$() function calls in the area of the script labeled
# as "Add ad-hoc character replacements". Alternatively, the user
# can select a csv file to be read as a list of replacements. The
# file must be in the form
#
# REPLACE,REPLACEMENT
#
# and only lines with one comma will be read.
#
# Written by Jose J. Atria (May 18, 2012)
# Last revision February 27, 2014
# Requires Praat v 5.3.63
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/utils.proc
include ../procedures/require.proc
@require("5.3.63")

form Extract sounds...
  positive Tier 1
  integer Padding_(s) 0
  boolean Preserve_times 0
  boolean Append_TextGrid_name 1
  boolean Count_labels_across_objects 0
  sentence Look_for
  boolean Objects_have_same_name 1
  boolean Make_character_replacements 1
  boolean Use_external_replacement_definition 0
endform

samename = objects_have_same_name
usedefinition = use_external_replacement_definition
makereplacements = make_character_replacements
addtextgridname = append_TextGrid_name
persistentcounter = count_labels_across_objects

new = 0
cleared = 0
total_labels = 0

if !makereplacements and usedefinition
  exitScript("Contradictory options. Replacement definitions are used for character replacements.")
endif

nsounds = numberOfSelected("Sound")
nlongsounds = numberOfSelected("LongSound")
nallsounds = nsounds + nlongsounds

ntextgrids = numberOfSelected("TextGrid")

if !nallsounds
  exitScript("No Sound object selected.")
endif
if !ntextgrids
  exitScript("No TextGrid object selected.")
endif

if nallsounds != ntextgrids
  exitScript("Number of Sound and TextGrid objects do not match.")
endif

for o to nsounds
  sound[o] = selected("Sound", o)
endfor
for o to nlongsounds
  longsound[o] = selected("LongSound", o)
endfor

for o to ntextgrids
  textgrid[o] = selected("TextGrid", o)
endfor

#Clear selection
selectObject(selected(1))
Copy: "remove"
Remove

for o to nsounds
  plusObject(sound[o])
endfor
for o to nlongsounds
  plusObject(longsound[o])
endfor
for o to nallsounds
  sound[o] = selected(o)
  s = sound[o]
endfor

if usedefinition
  replacement_file$ = chooseReadFile$("Select replacement definition file")
  if replacement_file$ = ""
    exitScript("No replacement definition selected.")
  endif

  replacement_table = Create Table with column names: "replacements", 0, "replace with"
  body$ readFile(replacement_file$')

  @split(newline$, body$)
  for i to split.length
    line$[i] = split.array$[i]
  endfor

  lines = split.length
  for i to lines
    line$ = line$[i]
    @split("," line$)
    if split.length = 2
      Append row
      change$ = split.array$[1]
      into$ = split.array$[2]
      r = Get number of rows
      Set string value: r, "replace", change$
      Set string value: r, "with", into$
    endif
  endfor
endif

if persistentcounter
  hash = Create Table with column names: "hash", 1, "placeholder"
  found$ = ""
endif

for o to nallsounds

  sound = sound[o]
  textgrid = textgrid[o]

  selectObject(sound)
  dsound = Get total duration
  if numberOfSelected("Sound")
    islong = 0
    sname$ = selected$("Sound")
  else
    islong = 1
    sname$ = selected$("LongSound")
  endif
  selectObject(textgrid)
  dtextgrid = Get total duration
  tname$ = selected$("TextGrid")

  # Check if objects are related
  related = 1
  if samename and sname$ != tname$
    related = 0
  endif
  if dsound != dtextgrid
    related = 0
  endif

  if !persistentcounter
    hash = Create Table with column names: "hash", 1, "placeholder"
    found$ = ""
  endif

  if related

    select textgrid
    ni = Get number of intervals: tier
    for i to ni
      select textgrid
      label$ = Get label of interval: tier, i
      # Perform initial label modifications here if desired
      label$ = replace$(label$, "*", "", 0)
      label$ = replace$(label$, " ", "", 0)
      if (look_for$ = "" and label$ != "") or (label$ != "" and label$ = look_for$)

        selectObject(hash)
        if index(found$, " " + label$ + " ")
          counter = Get value: 1, label$
          counter += 1
          Set numeric value: 1, label$, counter
        else
          counter = 1
          Append column: label$
          Set numeric value: 1, label$, counter
          found$ = found$ + " " + label$ + " "
        endif

        select textgrid
        start = Get start point: tier, i
        end = Get end point: tier, i

        select sound
        new += 1
        if islong
          extracted[new] = Extract part: start-padding, end+padding, preserve_times
        else
          extracted[new] = Extract part: start-padding, end+padding, "Rectangular", 1, preserve_times
        endif

        # Add ad-hoc character replacements
        if makereplacements
          if usedefinition
            selectObject(replacement_table)
            r = Get number of rows
            for d to r
              change$ = Get value: d, "replace"
              into$   = Get value: d, "with"
              label$  = replace$(label$, change$, into$, 0)
            endfor
          endif

          if index_regex(label$, "\W")
            # Perform other changes here, with lines like
            # label$ = replace$(label$, CHANGE, INTO, 0)
            # replacing CHANGE and INTO with whatever string
            # substitution you prefer
          endif

          if index_regex(label$, "[^a-zA-Z0-9-]")
            if !cleared
              clearinfo
              cleared = 1
            endif
            appendInfoLine("W: Label ", label$, " on Sound ", sname$, " still contains illegal characters.
              ...These will be lost.")
          endif

        endif
        selectObject(extracted[new])

        newname$ = ""
        if addtextgridname
            newname$ = tname$ + "_"
        endif
        newname$ = newname$ + label$ + "_" + string$(counter)
        Rename: newname$
      endif
    endfor
  else
    if !cleared
      clearinfo
      cleared = 1
    endif
    appendInfoLine("W: Sound ", sname$, " and TextGrid ", tname$, " do not seem to be related. Skipping.")
  endif
  if !persistentcounter
    removeObject(hash)
  endif
endfor

if usedefinition
  selectObject(replacement_table)
endif

if new
  selectObject(extracted[1])
  for i from 2 to new
    plusObject(extracted[i])
  endfor
endif
