## Static commands:

# Base menu
Add menu command: "Objects", "Praat", "JJATools",                           "",                 0, ""
Add menu command: "Objects", "Praat", "Save selected objects...",           "JJATools",         1, "save_all.praat"
Add menu command: "Objects", "Praat", "Copy selected objects...",           "JJATools",         1, "copy_selected.praat"
Add menu command: "Objects", "Praat", "View each selected",                 "JJATools",         1, "view_each.praat"
Add menu command: "Objects", "Praat", "Sort selected objects...",           "JJATools",         1, "sort_objects.praat"
Add menu command: "Objects", "Praat", "Batch generate Pitch (two-pass)...", "JJATools",         1, "batch_to_pitch_two-pass.praat"

# Formats menu
Add menu command: "Objects", "Praat", "Formats -",                          "JJATools",         1, ""
Add menu command: "Objects", "Praat", "TextGrids to Audacity labels...",    "Formats -",        2, "all_textgrids_to_audacity_labels.praat"
Add menu command: "Objects", "Praat", "Batch convert to JSON...",           "Formats -",        2, "batch_save_to_json.praat"
Add menu command: "Objects", "Praat", "Save selected objects to JSON...",   "Formats -",        2, "save_as_json.praat"

# Object selection menu
Add menu command: "Objects", "Praat", "Object selection",                   "JJATools",         1, ""
Add menu command: "Objects", "Praat", "Select one type...",                 "Object selection", 2, "select_one_type.praat"
Add menu command: "Objects", "Praat", "Invert selection",                   "Object selection", 2, "invert_selection.praat"

## Dynamic commands

Add action command: "Sound",         0, "",         0, "", 0, "Normalise (RMS)...",           "Modify -",              1, "rms_normalize.praat"
Add action command: "Sound",         0, "",         0, "", 0, "Filter and center...",         "Filter -",              1, "filter_and_center.praat"
Add action command: "Sound",         0, "TextGrid", 0, "", 0, "Extract labels...",            "",                      0, "extract_labels.praat"   
Add action command: "TextGrid",      1, "",         0, "", 0, "Find label...",                "Query -",               1, "find_label_in_textgrid.praat"
Add action command: "Sound",         0, "TextGrid", 0, "", 0, "View eachs as pairs",          "",                      0, "view_each.praat"
Add action command: "Sound",         0, "",         0, "", 0, "To Pitch (Hirst two-pass)...", "Analyse periodicity -", 1, "to_pitch_two-pass.praat"
Add action command: "Strings",       0, "",         0, "", 0, "Sort (generic)...",            "Modify -",              1, "sort_strings_generic.praat"
Add action command: "TextGrid",      0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "PointProcess",  0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "DurationTier",  0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "IntensityTier", 0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "Intensity",     0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "AmplitudeTier", 0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "PitchTier",     0, "",         0, "", 0, "Save as JSON file...",         "",                      0, "save_as_json.praat"
Add action command: "TextGrid",      0, "",         0, "", 0, "Save as Audacity label...",    "",                      0, "textgrid_to_audacity_label.praat"
