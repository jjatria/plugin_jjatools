include selection.proc

@saveSelectionTable()
selection = saveSelectionTable.table

select all

@minusSavedSelection(selection)
removeObject: selection
