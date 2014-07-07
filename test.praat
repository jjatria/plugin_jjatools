include .praat-dir/plugin_jjatools/selection_tools.proc
include .praat-dir/plugin_jjatools/utils.proc

# Test files created
n = 10
for i to n
  @pwgen(5)
  name$ = pwgen.return$
  test[i] = Create Sound as pure tone: name$, 1, 0, 0.4, 44100, 440, 0.2, 0.01, 0.01
endfor
pause Ten new sound files for testing, last one is selected

# Clear selection
@clearSelection()
pause Selection is now cleared

# Select sounds and save selection
for i to n
  plusObject(test[i])
endfor
@saveSelection()
pause Created files are now selected, and selection has been saved

# Change selection: new object created
new = Create Sound as pure tone: "new", 1, 0, 0.4, 44100, 440, 0.2, 0.01, 0.01
pause Selection has changed

# Restore previous selection
@restoreSelection()
pause Selection is restored

# Remove test object
removeObject(new)

# Save selection to table
@saveSelectionTable()
sounds = saveSelectionTable.table

# Generate a large number of new files and save that selection
noprogress To Pitch: 0, 75, 600
@saveSelectionTable()
pitchs = saveSelectionTable.table
pause Sounds are now Pitch objects, and they are selected

# Restore the previous selection
@restoreSavedSelection(sounds)
pause And now sounds are selected
Remove

# Restore the second saved selection
@restoreSavedSelection(pitchs)
Remove

# Create another object
new = Create Sound as pure tone: "new", 1, 0, 0.4, 44100, 440, 0.2, 0.01, 0.01
pause Now all objects are removed, except those pesky selection tables (and another test sound)

# Remove selection tables (but not other objects)
@removeSelectionTables()
pause Now those (and only those!) are gone too (note the sound is still there)

# Remove last object
removeObject(new)
