    form Explode TextGrid...
      integer Tier 1
      boolean Preserve_times 0
    endform

    interval = Is interval tier: tier
    if !interval
      exit Not an interval tier
    endif

    textgrid = selected("TextGrid")

    intervals = Get number of intervals: tier
    for i to intervals
      selectObject: textgrid
      start  = Get start point:       tier, i
      end    = Get end point:         tier, i
      label$ = Get label of interval: tier, i
      
      part[i] = Extract part: start, end, preserve_times
      Rename: label$
    endfor

    nocheck selectObject: undefined
    for i to intervals
      plusObject: part[i]
    endfor
