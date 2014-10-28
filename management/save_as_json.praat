# Praat object to JSON converter
#
# Written by Jose J. Atria (27 February 2014)
# Version 0.1
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc
include ../procedures/check_directory.proc
include ../procedures/json.proc
include ../procedures/utils.proc
include ../procedures/warnings.proc

form Save as JSON...
  sentence Save_to
  optionmenu Format: 1
    option Pretty printed
    option Minified
endform

@addWarning("AmplitudeTierAsIntensityTier",
  ..."AmplitudeTier objects saved as IntensityTier objects")

#   # Mapping of warning codes to messages
#   if .w$ = "AmplitudeTierAsIntensityTier"
#     .text$ = "W: AmplitudeTier objects saved as IntensityTier objects"
#   elsif index_regex(.w$, "Unsupported$")
#     .text$ = "W: " +
#       ...replace_regex$(.w$, "(.*)Unsupported", "\1", 0) +
#       ... " objects not yet supported"
#   endif

@checkDirectory(save_to$, "Save JSON to...")
directory$ = checkDirectory.name$

@saveSelection()

if format$ = "Pretty printed"
  n$ = newline$
  t$ = tab$
  s$ = " "
elsif format$ = "Minified"
  n$ = ""
  t$ = n$
  s$ = n$
endif

for i to saveSelection.n
  # Reset fallback flag for this object
  # If this object requires a fallback, then this will
  # be set somewhere else in the loop
  fallback = 0

  selectObject(saveSelection.id[i])
  type$ = extractWord$(selected$(), "")

  if type$ = "AmplitudeTier"
    @warning("AmplitudeTierAsIntensityTier")
    fallback_to = selected()
    fallback = To IntensityTier: -10000
  endif
  # If an objects requires a fallback, this is selected
  if fallback
    selectObject(fallback)
    type$ = extractWord$(selected$(), "")
  else
    selectObject(saveSelection.id[i])
  endif

  name$ = selected$(type$)
  start = Get start time
  end = Get end time
  output_file$ = directory$ + "/" +
    ...name$ + "_" + replace_regex$(type$, "(.)", "\L\1", 0) + ".json"

  if type$ = "TextGrid"
    json_type$ = "textgrid"
  elsif type$ = "PointProcess"
    json_type$ = "points"
  elsif type$ = "PitchTier" or
    ... type$ = "DurationTier" or
    ... type$ = "AmplitudeTier" or
    ... type$ = "IntensityTier"
    json_type$ = "points with numbers"
  elsif type$ = "Intensity"
    json_type$ = "frames"
  else
    json_type$ = "unsupported"
  endif

  if json_type$ != "unsupported"
    if fileReadable(output_file$)
      deleteFile: output_file$
    endif

    @startJsonObject(output_file$)
    @writeJsonString(output_file$, "File type", "json", 0)
    @writeJsonString(output_file$, "Object class", type$, 0)
    @writeJsonNumber(output_file$, "start", start, 0)
    @writeJsonNumber(output_file$, "end", end, 0)

    if json_type$ = "textgrid"

      @startJsonList(output_file$, "tiers")

      tiers = Get number of tiers
      for t to tiers
        last = if t = tiers then 1 else 0 fi
        @writeJsonTgTier(output_file$, t, last)
      endfor

      @endJsonList(output_file$, 1)

    elsif extractWord$(json_type$, "") = "points"

      points = Get number of points
      list_name$ = "points"

      if points

        # DurationTier objects had no query methods prior to 5.3.70
        # We need to hack our way to the value of the duration points
        if praatVersion < 5370 and type$ = "DurationTier"
          @setUpDurationTierHack(selected())
        endif

        @startJsonList(output_file$, list_name$)

        for p to points
          last = if p = points then 1 else 0 fi
          time = Get time from index: p
          if json_type$ = "points with numbers"

            if type$ = "DurationTier" and praatVersion < 5370
              @queryDurationTierHack(selected(), time)
              value = queryDurationTierHack.value
            else
              value = Get value at index: p
            endif

            @writeJsonPointWithNumber(output_file$, time, value, last)
          elsif json_type$ = "points"
            @pushToJsonList(output_file$, time, last)
          endif
        endfor

        if praatVersion < 5370 and type$ = "DurationTier"
          @cleanUpDurationTierHack(selected())
        endif

        @endJsonList(output_file$, 1)

      else

        @writeJsonEmptyList(output_file$, list_name$, 1)

      endif
    elsif json_type$ = "frames"
      # This type is really a subset of the "points" type.
      # Annoyingly, method names are different. Maybe a more
      # general approach can be found?
      frames = Get number of frames
      list_name$ = "frames"
      if frames
        @startJsonList(output_file$, list_name$)
        for f to frames
          last = if f = frames then 1 else 0 fi
          value = Get value in frame: f
          @pushToJsonList(output_file$, value, last)
        endfor
        @endJsonList(output_file$, 1)
      else
        @writeJsonEmptyList(output_file$, list_name$, 1)
      endif
    else
      # Unsupported object
    endif

    @endJsonObject(output_file$, 1)
  else
    @addWarning(type$ + "Unsupported",
      ...type$ + " objects not yet supported")
    @warning(type$ + "Unsupported")
  endif

  if fallback
    removeObject(fallback)
    selectObject(saveSelection.id[i])
  endif

endfor

@restoreSelection()

@issueWarnings()

# Hack to query DurationTier objects for Praat <5.3.70
procedure setUpDurationTierHack (.id)
  .full = Copy: "full"
  .blank = Copy: "blank"
  .points = Get number of points
  for .p to .points
    .time = Get time from index: .p
    selectObject(.blank)
    Remove point: .p
    Add point: .p, 1
    selectObject(.id)
  endfor
endproc

procedure queryDurationTierHack (.id, .time)
  selectObject(setUpDurationTierHack.full)
  .new_duration = Get target duration: 0, .time
  Remove point: 1
  selectObject(setUpDurationTierHack.blank)
  .old_duration = Get target duration: 0, .time
  .value = .new_duration / .old_duration
  Remove point: 1
  selectObject(.id)
endproc

procedure cleanUpDurationTierHack (.id)
  removeObject(setUpDurationTierHack.full, setUpDurationTierHack.blank)
  selectObject(.id)
endproc
