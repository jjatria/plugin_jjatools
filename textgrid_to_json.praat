# TextGrid to JSON converter
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

include check_directory.proc

form TextGrid to JSON...
  sentence Save_to
  optionmenu Format: 1
    option Pretty printed
    option Minified
endform

@checkDirectory(save_to$, "Save JSON to...")
directory$ = checkDirectory.name$

textgrids = numberOfSelected("TextGrid")

if format$ = "Pretty printed"
  n$ = newline$
  t$ = tab$
  s$ = " "
elsif format$ = "Minified"
  n$ = ""
  t$ = n$
  s$ = n$
endif
  
for tg to textgrids
  tg[tg] = selected("TextGrid", tg)
endfor

for tg to textgrids
  selectObject(tg[tg])

  name$ = selected$("TextGrid")
  out_file$ = directory$ + "/" + name$ + ".json"

  writeFile(out_file$,
    ..."{", n$,
    ...t$, """File type"":",    s$, """json"",",     n$,
    ...t$, """Object class"":", s$, """TextGrid"",", n$)

  sound_start = Get start time
  sound_end = Get end time

  appendFile(out_file$,
    ...t$, """xmin"":",  s$, "", sound_start, ",", n$,
    ...t$, """xmax"":",  s$, "", sound_end,   ",", n$,
    ...t$, """tiers"":", n$,
    ...t$, "[", n$)

  tiers = Get number of tiers
  for t to tiers

    interval = Is interval tier: t
    tier_type$ = if interval then "IntervalTier" else "TextTier" fi
    tier_name$ = Get tier name: t
    
    appendFile(out_file$,
      ...t$+t$, "{", n$,
      ...t$+t$+t$, """class"":", s$, """", tier_type$,  """,", n$,
      ...t$+t$+t$, """name"":",  s$, """", tier_name$,  """,", n$,
      ...t$+t$+t$, """xmin"":",  s$, "",   sound_start,   ",", n$,
      ...t$+t$+t$, """xmax"":",  s$, "",   sound_end,     ",", n$)

    items_name$ = if interval then "intervals" else "points" fi
    appendFile(out_file$,
      ...t$, t$, t$, """", items_name$, """:", s$, "")

    if interval
      items = Get number of intervals: t
    else
      items = Get number of points: t
    endif
    if !items
      if interval
        appendFile(out_file$, n$)
        @writeInterval(out_file$, sound_start, sound_end, "", 1)
      else
        appendFile(out_file$, "[]", n$)
      endif
    else

      appendFile(out_file$, n$,
        ...t$+t$+t$, "[", n$)

      for u to items
        last = if u = items then 1 else 0 fi
        if interval
          label$ = Get label of interval: t, u
          @sanitizeString(label$)
          label$ = sanitizeString.str$
          start = Get start point: t, u
          end = Get end point: t, u
          @writeInterval(out_file$, start, end, label$, last)
        else
          label$ = Get label of point: t, u
          @sanitizeString(label$)
          label$ = sanitizeString.str$
          time = Get time of point: t, u
          @writePoint(out_file$, time, label$, last)
        endif
      endfor

      appendFile(out_file$,
        ...t$+t$+t$, "]", n$)

    endif

    closing$ = if t = tiers then "}" else "}," fi
    appendFile(out_file$,
      ...t$, t$, closing$, n$)

  endfor

  appendFile(out_file$,
    ...t$, "]", n$,
    ..."}", n$)
endfor

if textgrids
  selectObject(tg[1])
  for tg from 2 to textgrids
    plusObject(tg[tg])
  endfor
endif

procedure sanitizeString (.str$)
  .str$ = replace$(.str$, """", "\""", 0)
endproc

procedure writeInterval (.out$, .start, .end, .label$, .last)
  .closing$ = if .last then "}" else "}," fi
  appendFile(.out$,
    ...t$+t$+t$+t$, "{", n$,
    ...t$+t$+t$+t$+t$, """xmin"":", s$, "",   .start,   ",", n$,
    ...t$+t$+t$+t$+t$, """xmax"":", s$, "",   .end,     ",", n$,
    ...t$+t$+t$+t$+t$, """text"":", s$, """", .label$, """", n$,
    ...t$+t$+t$+t$, .closing$, n$)
endproc

procedure writePoint (.out$, .time, .label$, .last)
  .closing$ = if .last then "}" else "}," fi
  appendFile(.out$,
    ...t$+t$+t$+t$, "{", n$,
    ...t$+t$+t$+t$+t$, """number"":", s$, "",   .time,    ",", n$,
    ...t$+t$+t$+t$+t$, """mark"":",   s$, """", .label$, """", n$,
    ...t$+t$+t$+t$, .closing$, n$)
endproc
