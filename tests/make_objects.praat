# Creates sample versions of all Praat objects
select all
Remove

include .praat-dir/plugin_jjatools/procedures/selection.proc

@createEmptySelectionTable()
objects = createEmptySelectionTable.table

default.intervals = 4
default.points = 3
default.channels = 2

Create SpeechSynthesizer: "English", "m3"
@addToSelectionTable(objects, selected())
To Sound: "This is some text.", "yes"
@addToSelectionTable(objects, selected("Sound"))
@addToSelectionTable(objects, selected("TextGrid"))

@get("TextGrid")
selectObject: get.id
@get("Sound")
Insert point tier: 1, "points"
labels$ = "ɕɣ4a"
for i to default.points-1
  Insert point: 1, Object_'get.id'.xmax * (i / default.points),
    ... mid$(labels$, i mod length(labels$), 1)
endfor

selectObject: get.id
To CrossCorrelationTable: 0, 10, 0
@addToSelectionTable(objects, selected())
To CrossCorrelationTables
@addToSelectionTable(objects, selected())
To Diagonalizer: 100, 0.001, "ffdiag"
@addToSelectionTable(objects, selected())
To MixingMatrix
@addToSelectionTable(objects, selected())

selectObject: get.id
To Pitch: 0, 75, 600
@addToSelectionTable(objects, selected())
Down to PitchTier
@addToSelectionTable(objects, selected())

selectObject: get.id
To Intensity: 100, 0, "yes"
@addToSelectionTable(objects, selected())
Down to IntensityTier
@addToSelectionTable(objects, selected())
To AmplitudeTier
@addToSelectionTable(objects, selected())

selectObject: get.id
To PointProcess (periodic, cc): 75, 600
@addToSelectionTable(objects, selected())
Up to TextTier: "a"
@addToSelectionTable(objects, selected())

selectObject: get.id
To Spectrum: "yes"
@addToSelectionTable(objects, selected())

selectObject: get.id
To Ltas: 100
@addToSelectionTable(objects, selected())

selectObject: get.id
To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
@addToSelectionTable(objects, selected())

selectObject: get.id
To Cochleagram: 0.01, 0.1, 0.03, 0.03
@addToSelectionTable(objects, selected())

selectObject: get.id
To FormantFilter: 0.015, 0.005, 100, 50, 0, 1.1, 75, 600
@addToSelectionTable(objects, selected())

selectObject: get.id
To BarkFilter: 0.015, 0.005, 1, 1, 0
@addToSelectionTable(objects, selected())

selectObject: get.id
To MelFilter: 0.015, 0.005, 100, 100, 0
@addToSelectionTable(objects, selected())

selectObject: get.id
To Formant (burg): 0, 5, 5500, 0.025, 50
@addToSelectionTable(objects, selected())

selectObject: get.id
To LPC (burg): 16, 0.025, 0.005, 50
@addToSelectionTable(objects, selected())

selectObject: get.id
To MFCC: 12, 0.015, 0.005, 100, 100, 0
@addToSelectionTable(objects, selected())

selectObject: get.id
To Harmonicity (cc): 0.01, 75, 0.1, 1
@addToSelectionTable(objects, selected())

selectObject: get.id
To Manipulation: 0.01, 75, 600
@addToSelectionTable(objects, selected())
Extract duration tier
@addToSelectionTable(objects, selected())

selectObject: get.id
To KlattGrid (simple): 0.005, 5, 5500, 0.025, 50, 60, 600, 100, "yes"
@addToSelectionTable(objects, selected())

Create Strings as file list: "files", preferencesDirectory$ + "*wav"
@addToSelectionTable(objects, selected())
To WordList
@addToSelectionTable(objects, selected())

Create TableOfReal (Weenink 1985): "Men"
@addToSelectionTable(objects, selected())
To ContingencyTable
@addToSelectionTable(objects, selected())
To Matrix
@addToSelectionTable(objects, selected())
To Excitation
@addToSelectionTable(objects, selected())
To Excitations
@addToSelectionTable(objects, selected())
To Pattern: 1
@addToSelectionTable(objects, selected())

Create letter R example: 32.5
@addToSelectionTable(objects, selected())
To Weight
@addToSelectionTable(objects, selected())

Create Permutation: "p", 10, "yes"
@addToSelectionTable(objects, selected())

Create Polynomial: "p", -3, 4, "2 -1 -2 1"
@addToSelectionTable(objects, selected())
To Roots
@addToSelectionTable(objects, selected())

Create LegendreSeries: "ls", -1, 1, "0 0 1"
@addToSelectionTable(objects, selected())

Create ChebyshevSeries: "cs", -1, 1, "0 0 1"
@addToSelectionTable(objects, selected())

Create MSpline: "mspline", 0, 1, 2, "1.2 2 1.2 1.2 3 0", "0.3 0.5 0.6"
@addToSelectionTable(objects, selected())

Create ISpline: "ispline", 0, 1, 3, "1.2 2 1.2 1.2 3 0", "0.3 0.5 0.6"
@addToSelectionTable(objects, selected())

Create Articulation: "articulation"
@addToSelectionTable(objects, selected())

Create Speaker: "speaker", "Female", "2"
@addToSelectionTable(objects, selected())

@get("Art")
plusObject: get.id
To VocalTract
@addToSelectionTable(objects, selected())
To VocalTractTier: 0, 1, 0.5
@addToSelectionTable(objects, selected())

Create Artword: "hallo", 1
@addToSelectionTable(objects, selected())


Create simple Photo: "xy", 10, 10, "x*y/100", "x*y/100", "x*y/100"
@addToSelectionTable(objects, selected())

Create simple Confusion: "simple", "u i a"
@addToSelectionTable(objects, selected())

Create simple Covariance: "c", "1.0 0.0 1.0", "0.0 0.0", 100
@addToSelectionTable(objects, selected())
To PCA
@addToSelectionTable(objects, selected())

@get("Covariance")
selectObject: get.id
To Correlation
@addToSelectionTable(objects, selected())

Create empty EditCostsTable: "editCosts", 0, 0
@addToSelectionTable(objects, selected())

Create FormantGrid: "schwa", 0, 1, 10, 550, 1100, 60, 50
@addToSelectionTable(objects, selected())

Create Poisson process: "poisson", 0,1, 100
@addToSelectionTable(objects, selected())

@get("Dissimilarity")
selectObject: get.id
To Distance: "yes"
@addToSelectionTable(objects, selected())
To ScalarProduct: "yes"
@addToSelectionTable(objects, selected())

@get("Pattern")
selectObject: get.id
To Categories: 1, 0.0000001, 1000
@addToSelectionTable(objects, selected())

# Replace sound with shorter one

@get("Sound")
removeObject: get.id
@removeFromSelectionTable(objects, get.id)

for i to default.channels
  channel[i] = Create Sound as pure tone: "a", 1, 0, 0.05, 44100, 440, 0.2, 0.01, 0.01
endfor
@clearSelection()
for i to default.channels
  plusObject: channel[i]
endfor
Combine to stereo
Rename: "sound"
@addToSelectionTable(objects, selected())

for i to default.channels
  removeObject: channel[i]
endfor

selectObject: objects

procedure get (.type$)
  @saveSelection()
  selectObject: objects
  .n = Search column: "type", .type$
  .id = Object_'objects'[.n, "id"]
  @restoreSelection()
endproc
