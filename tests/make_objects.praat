# Creates sample versions of all Praat objects

default.intervals = 4
default.points = 3
default.channels = 2

for i to default.channels
  channel[i] = Create Sound as pure tone: "a", 1, 0, 0.05, 44100, 440, 0.2, 0.01, 0.01
endfor
nocheck selectObject: undefined
for i to default.channels
  plusObject: channel[i]
endfor

sound = Combine to stereo
Rename: "sound"

for i to default.channels
  removeObject: channel[i]
endfor

speechsynthesizer = Create SpeechSynthesizer: "English", "m3"
To Sound: "This is some text.", "yes"
sound_base = selected("Sound")
textgrid = selected("TextGrid")

selectObject: textgrid
Insert point tier: 1, "points"
labels$ = "ɕɣ4a"
for i to default.points-1
  Insert point: 1, Object_'sound_base'.xmax * (i / default.points),
    ... mid$(labels$, i mod length(labels$), 1)
endfor

selectObject: sound_base
crosscorrelationtable = To CrossCorrelationTable: 0, 10, 0
crosscorrelationtables = To CrossCorrelationTables
diagonalizer = To Diagonalizer: 100, 0.001, "ffdiag"
mixingmatrix = To MixingMatrix

selectObject: sound_base
pitch = To Pitch: 0, 75, 600
pitchtier = Down to PitchTier

tableofreal = Create TableOfReal (Weenink 1985): "Men"
table = To Table: "rowLabel"
matrix = Down to Matrix
excitation = To Excitation
excitations = To Excitations
pattern = To Pattern: 1
dissimilarity = To Dissimilarity
weight = To Weight

selectObject: dissimilarity
distance = To Distance: "yes"
scalarproduct = To ScalarProduct: "yes"

selectObject: pattern
categories = To Categories: 1, 0.0000001, 1000

selectObject: sound_base
intensity = To Intensity: 100, 0, "yes"
intensitytier = Down to IntensityTier
amplitudetier = To AmplitudeTier

selectObject: sound_base
pointprocess = To PointProcess (periodic, cc): 75, 600
texttier = To TextTier: "a"

selectObject: sound_base
spectrum = To Spectrum: "yes"

selectObject: sound_base
ltas = To Ltas: 100

selectObject: sound_base
spectrogram = To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"

selectObject: sound_base
cochleagram = To Cochleagram: 0.01, 0.1, 0.03, 0.03

selectObject: sound_base
formantfilter = To FormantFilter: 0.015, 0.005, 100, 50, 0, 1.1, 75, 600

selectObject: sound_base
barkfilter = To BarkFilter: 0.015, 0.005, 1, 1, 0

selectObject: sound_base
melfilter = To MelFilter: 0.015, 0.005, 100, 100, 0

selectObject: sound_base
formant = To Formant (burg): 0, 5, 5500, 0.025, 50

selectObject: sound_base
lpc = To LPC (burg): 16, 0.025, 0.005, 50

selectObject: sound_base
mfcc = To MFCC: 12, 0.015, 0.005, 100, 100, 0

selectObject: sound_base
harmonicity = To Harmonicity (cc): 0.01, 75, 0.1, 1

selectObject: sound_base
matrix = Down to Matrix

selectObject: sound_base
manipulation = To Manipulation: 0.01, 75, 600

selectObject: sound_base
klattgrid = To KlattGrid (simple): 0.005, 5, 5500, 0.025, 50, 60, 600, 100, "yes"

