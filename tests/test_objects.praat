jjatools$ = preferencesDirectory$ + "/plugin_jjatools/"

include .praat-dir/plugin_jjatools/procedures/selection.proc
include .praat-dir/plugin_jjatools/procedures/utils.proc

@mktemp("")
dir$ = mktemp.name$

@saveSelection()
for i to saveSelection.n
  selectObject: saveSelection.id[i]

  type$[1]  = extractWord$(selected$(), "")
  name$[1] = selected$(type$[1])

  appendInfo: type$[1], "... "

  nocheck runScript: jjatools$ + "management/save_as_json.praat",
    ... dir$ + "test.json", "Data stream", "yes"
  @clearSelection()
  nocheck runScript: jjatools$ + "management/read_from_json.praat",
    ... dir$ + "test.json"

  if numberOfSelected(type$[1])
    type$[2]  = extractWord$(selected$(), "")
    name$[2] = selected$(type$[2])
    if type$[1] = type$[2] and name$[1] = name$[2]
      appendInfoLine: "OK"
    else
      appendInfoLine: "Fail"
    endif
  else
    appendInfoLine: "Fail"
  endif
  
  Remove
endfor

deletefile: dir$
@restoreSelection()
