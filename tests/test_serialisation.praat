jjatools$ = preferencesDirectory$ + "/plugin_jjatools/"

include ../procedures/selection.proc
include ../procedures/utils.proc

# To use selected objects
# @saveSelectionTable()
# selection = saveSelectionTable.table

# To test all* objects
runScript: "make_objects.praat"
selection = selected()
Randomize rows
@restoreSavedSelection(selection)

# To test small sample of objects
# a = Create SpeechSynthesizer: "English", "m3"
# To Sound: "This is some text.", "yes"
# plusObject: a
# @saveSelectionTable()
# selection = saveSelectionTable.table

last = numberOfSelected()

@mktemp("testserial.XXXXX")
dir$ = mktemp.name$

for i to last
  error = 0
  selectObject: Object_'selection'[i, "id"]

  type$[1]  = extractWord$(selected$(), "")
  name$[1] = selected$(type$[1])

  json_file$ = dir$ + name$[1] + ".json"

  nocheck runScript: jjatools$ + "management/save_as_json.praat",
    ... json_file$, "Data stream", "yes"
  error += if !fileReadable(json_file$) then 10 else 0 fi

  @clearSelection()

  nocheck runScript: jjatools$ + "management/read_from_json.praat",
    ... json_file$

  deleteFile: json_file$

  if numberOfSelected()
    type$[2]  = extractWord$(selected$(), "")
    name$[2] = selected$(type$[2])
    error += if type$[1] != type$[2] then 1 else 0 fi
    error += if name$[1] != name$[2] then 2 else 0 fi
    Remove
  else
    error += 20
  endif
  @zeropad(error, 2)
  error$ = zeropad.return$
  appendInfoLine: if error then "Fail" else "OK  " fi +
    ... tab$ + type$[1] + " (" + error$ + ")"
endfor

removeObject: selection
deleteFile: dir$

# Error codes
#
# 1? : Writing error
# 2? : Reading error
# 3? : R+W error
#
# ?1 : Type error
# ?2 : Name error
# ?3 : Name and type error
