# Selects one single type of object
#
# Written by Jose J. Atria
# Last revision: 6 February 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc

form Select one type...
  optionmenu Type: 1
    option ...
    option Activation
    option AffineTransform
    option AmplitudeTier
    option Art
    option Artword
    option Autosegment
    option BarkFilter
    option CCA
    option Categories
    option Cepstrum
    option Cepstrumc
    option ChebyshevSeries
    option ClassificationTable
    option Cochleagram
    option Collection
    option Configuration
    option Confusion
    option ContingencyTable
    option Corpus
    option Correlation
    option Covariance
    option CrossCorrelationTable
    option CrossCorrelationTables
    option DTW
    option Diagonalizer
    option Discriminant
    option Dissimilarity
    option Distance
    option Distributions
    option DurationTier
    option EEG
    option ERP
    option ERPTier
    option Eigen
    option Excitation
    option Excitations
    option ExperimentMFC
    option FFNet
    option FeatureWeights
    option Formant
    option FormantFilter
    option FormantGrid
    option FormantPoint
    option FormantTier
    option GaussianMixture
    option HMM
    option HMM_Observation
    option HMM_ObservationSequence
    option HMM_State
    option HMM_StateSequence
    option Harmonicity
    option ISpline
    option Index
    option Intensity
    option IntensityTier
    option IntervalTier
    option KNN
    option KlattGrid
    option KlattTable
    option LFCC
    option LPC
    option Label
    option LegendreSeries
    option LinearRegression
    option LogisticRegression
    option LongSound
    option Ltas
    option MFCC
    option MSpline
    option ManPages
    option Manipulation
    option Matrix
    option MelFilter
    option MixingMatrix
    option Movie
    option Network
    option OTGrammar
    option OTHistory
    option OTMulti
    option PCA
    option PairDistribution
    option ParamCurve
    option Pattern
    option Permutation
    option Pitch
    option PitchTier
    option PointProcess
    option Polygon
    option Polynomial
    option Procrustes
    option RealPoint
    option RealTier
    option ResultsMFC
    option Roots
    option SPINET
    option SSCP
    option SVD
    option Salience
    option ScalarProduct
    option Similarity
    option SimpleString
    option SortedSetOfString
    option Sound
    option Speaker
    option Spectrogram
    option Spectrum
    option SpectrumTier
    option SpeechSynthesizer
    option SpellingChecker
    option Strings
    option StringsIndex
    option Table
    option TableOfReal
    option TextGrid
    option TextInterval
    option TextPoint
    option TextTier
    option Tier
    option Transition
    option VocalTract
    option Weight
    option WordList
  boolean Refine_current_selection yes
endform

if refine_current_selection
  @refineToType(type$)
else
  @selectType(type$)
endif
