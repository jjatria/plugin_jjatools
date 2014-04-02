Add menu command... Objects Praat "JJATools" "" 0
Add menu command... Objects Praat "File conversions" "JJATools" 1
Add menu command... Objects Praat "Save selected objects" "JJATools" 1 save_all.praat
Add menu command... Objects Praat "TextGrids to Audacity labels" "File conversions" 2 all_textgrids_to_audacity_labels.praat
Add menu command... Objects Praat "Batch convert to JSON" "File conversions" 2 batch_save_to_json.praat

Add action command... Sound        0 ""       0 "" 0 "Filter and center selected sounds" "Modify" 1 filter_and_center.praat
Add action command... Sound        0 TextGrid 0 "" 0 "Extract labels..."                 ""       0 extract_labels.praat
Add action command... TextGrid     1 ""       0 "" 0 "Find label..."                     "Query"  1 find_label_in_textgrid.praat
Add action command... Sound        0 ""       0 "" 0 "View each..."                      ""       0 view_each.praat
Add action command... Sound        0 TextGrid 0 "" 0 "View each..."                      ""       0 view_each.praat
Add action command... Strings      0 ""       0 "" 0 "Sort (generic)..."                 "Modify" 1 sort_strings_generic.praat
Add action command... TextGrid     0 ""       0 "" 0 "Save as JSON file..."              ""       1 save_as_json.praat
Add action command... PointProcess 0 ""       0 "" 0 "Save as JSON file..."              ""       1 save_as_json.praat
Add action command... DurationTier 0 ""       0 "" 0 "Save as JSON file..."              ""       1 save_as_json.praat
Add action command... PitchTier    0 ""       0 "" 0 "Save as JSON file..."              ""       1 save_as_json.praat
Add action command... TextGrid     0 ""       0 "" 0 "Save as Audacity label..."         ""       1 textgrid_to_audacity_label.praat
