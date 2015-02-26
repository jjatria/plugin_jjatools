# Creates sample versions of all Praat objects
select all
nocheck Remove

include ../procedures/selection.proc
include ../procedures/utils.proc

@mktemp("mkobj.XXXXX")
dir$ = mktemp.name$

@createEmptySelectionTable()
objects = createEmptySelectionTable.table

default.intervals = 4
default.points = 3
default.channels = 2

Create SpeechSynthesizer: "English", "m3"
@add()
To Sound: "This is some text.", "yes"
@add()

@select("TextGrid")
@get("Sound")
Insert point tier: 1, "points"
labels$ = "ɕɣ4a"
for i to default.points-1
  Insert point: 1, Object_'get.id'.xmax * (i / default.points),
    ... mid$(labels$, i mod length(labels$), 1)
endfor

selectObject: get.id
To CrossCorrelationTable: 0, 10, 0
@add()
To CrossCorrelationTables
@add()
To Diagonalizer: 100, 0.001, "ffdiag"
@add()
To MixingMatrix
@add()

selectObject: get.id
To Pitch: 0, 75, 600
@add()
Down to PitchTier
@add()

selectObject: get.id
To Intensity: 100, 0, "yes"
@add()
Down to IntensityTier
@add()
To AmplitudeTier
@add()

select all
@saveSelectionTable()
selectObject: saveSelectionTable.table
@add()

selectObject: get.id
To PointProcess (periodic, cc): 75, 600
@add()
Up to TextTier: "a"
@add()

a = Create Configuration: "Configuration", 10, 2, "self*2"
b = Create Configuration: "Configuration", 10, 2, "self*3"
@add()
selectObject: a, b
To Procrustes: 1
@add()
selectObject: a, b
To AffineTransform (congruence): 50, 1e-6
@add()
removeObject: a

selectObject: get.id
To Spectrum: "yes"
@add()

selectObject: get.id
To Ltas: 100
@add()

selectObject: get.id
To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
@add()

selectObject: get.id
To Cochleagram: 0.01, 0.1, 0.03, 0.03
@add()

selectObject: get.id
To FormantFilter: 0.015, 0.005, 100, 50, 0, 1.1, 75, 600
@add()

selectObject: get.id
To BarkFilter: 0.015, 0.005, 1, 1, 0
@add()

selectObject: get.id
To MelFilter: 0.015, 0.005, 100, 100, 0
@add()

selectObject: get.id
To Formant (burg): 0, 5, 5500, 0.025, 50
@add()

selectObject: get.id
To LPC (burg): 16, 0.025, 0.005, 50
@add()

selectObject: get.id
To MFCC: 12, 0.015, 0.005, 100, 100, 0
@add()

selectObject: get.id
To Harmonicity (cc): 0.01, 75, 0.1, 1
@add()

selectObject: get.id
To Manipulation: 0.01, 75, 600
@add()
Extract duration tier
@add()

selectObject: get.id
To KlattGrid (simple): 0.005, 5, 5500, 0.025, 50, 60, 600, 100, "yes"
@add()
Extract flutter tier
@add()

Create NoCoda grammar
@add()
To PairDistribution: 100000, 2
@add()

Create rectangular Network: 0.01, "linear", 0, 1, 1, 0.1, -1, 1, 0, 10, 10, "yes", -0.1, 0.1
@add()

Create Strings as file list: "files", preferencesDirectory$ + "*wav"
@add()
To WordList
@add()

Create TableOfReal (Weenink 1985): "Men"
@add()
To SSCP: 1, 120, 1, 3
@add()
@get("TableOfReal")
selectObject: get.id
To ContingencyTable
@add()
To Matrix
@add()
To Excitation
@add()
To Excitations
@add()

Create letter R example: 32.5
@add()
To Weight
@add()

Create Permutation: "p", 10, "yes"
@add()

Create Polynomial: "p", -3, 4, "2 -1 -2 1"
@add()
To Roots
@add()

Create LegendreSeries: "ls", -1, 1, "0 0 1"
@add()

Create ChebyshevSeries: "cs", -1, 1, "0 0 1"
@add()

Create MSpline: "mspline", 0, 1, 2, "1.2 2 1.2 1.2 3 0", "0.3 0.5 0.6"
@add()

Create ISpline: "ispline", 0, 1, 3, "1.2 2 1.2 1.2 3 0", "0.3 0.5 0.6"
@add()

Create Articulation: "articulation"
@add()

Create Speaker: "speaker", "Female", "2"
@add()

Create iris example: 0, 0
@add()

@minus("Categories")
To Activation: 1
@add()

@select("Categories")
@plus("Pattern")
To KNN Classifier: "Classifier", "Random"
@add()
@plus("Categories")
@plus("Pattern")
To FeatureWeights: 0.02, 20, 1, "Co-optimization", 1, "Flat"
@add()

@select("Speaker")
@plus("Art")
To VocalTract
@add()
To VocalTractTier: 0, 1, 0.5
@add()

Create Artword: "hallo", 1
@add()

Create simple Photo: "xy", 10, 10, "x*y/100", "x*y/100", "x*y/100"
@add()

Create simple Confusion: "simple", "u i a"
@add()

Create simple Covariance: "c", "1.0 0.0 1.0", "0.0 0.0", 100
@add()
To PCA
@add()

Create KlattTable example
@add()
Save as text file: dir$ + "example.KlattTable"

Create FileInMemory: dir$ + "example.KlattTable"
@add()
deleteFile: dir$ + "example.KlattTable"
To FilesInMemory
@add()

Create HMM: "hmm", "no", 3, 3
@add()
To HMM_ObservationSequence: 0, 20
@add()
@plus("HMM")
To HMM_StateSequence
@add()

Create simple Polygon: "p", "0.0 0.0  0.0 1.0  1.0 0.0"
@add()

@select("Covariance")
To Correlation
@add()

Create empty EditCostsTable: "editCosts", 0, 0
@add()

Create FormantGrid: "schwa", 0, 1, 10, 550, 1100, 60, 50
@add()

Create Poisson process: "poisson", 0,1, 100
@add()

@select("Dissimilarity")
To Distance: "yes"
@add()
To ScalarProduct: "yes"
@add()

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
@add()

for i to default.channels
  removeObject: channel[i]
endfor

deleteFile: dir$
selectObject: objects

procedure get (.type$)
  @saveSelection()
  selectObject: objects
  .n = Search column: "type", .type$
  .id = Object_'objects'[.n, "id"]
  @restoreSelection()
endproc

procedure plus (.type$)
  @get(.type$)
  nocheck plusObject: get.id
endproc

procedure minus (.type$)
  @get(.type$)
  nocheck minusObject: get.id
endproc

procedure select (.type$)
  @get(.type$)
  nocheck selectObject: get.id
endproc

procedure remove (.type$)
  @get(.type$)
  nocheck removeObject: get.id
endproc

procedure add ()
  @saveSelection()
  for .i to saveSelection.n
    @addToSelectionTable(objects, saveSelection.id[.i])
  endfor
  @restoreSelection()
endproc
