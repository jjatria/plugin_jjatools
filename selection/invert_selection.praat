include main.proc

@saveSelectionTable()
selection = saveSelectionTable.table

select all

@minusSavedSelection(selection)
removeObject: selection
