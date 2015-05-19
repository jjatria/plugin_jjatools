#!/usr/bin/perl

# Data de-serialisation script for Praat
#
# Written by Jose J. Atria (February 14, 2015)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

use warnings;
use strict;
use diagnostics;
binmode STDOUT, ':utf8';
use 5.010;

BEGIN {
  my @use = (
    'use Data::Dumper',
    'use File::Slurp',
    'use Pod::Usage',
    'use Getopt::Long qw(:config no_ignore_case)',
    'use Encode qw(encode decode)',
    'use YAML::XS',
    'use Try::Tiny',
    'use Readonly',
  );
  my $missing = 0;
  foreach (@use) {
    eval $_;
    if ($@) {
      if ($@ =~ /Can't locate (\S+)/) {
        $missing = 1;
        warn "W: Module $1 is not installed\n";
      }
      else { die $@; }
    }
  }
  if ($missing) {
    warn "E: Unmet dependencies. Please install the missing modules before ",
      "continuing.\n";
    exit 0;
  }
}

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';

Readonly my %BOOLEAN = (
  gm                            => 1,
  clamped                       => 1,
);
Readonly my %STRINGS = (
  class                         => 1,
  name                          => 1,
  text                          => 1,
  label                         => 1,
  labels                        => 1,
  string                        => 1,
  string1                       => 1,
  string2                       => 1,
  strings                       => 1,
  mark                          => 1,
  columnLabels                  => 1,
  voiceVariantName              => 1,
  voiceLanguageName             => 1,
);
Readonly my %SIZED_LISTS = (
  intervals                     => 1,
  points                        => 1,
  rows                          => 1,
  outputCategories              => 1,
  vocalTracts                   => 1,
  formants                      => 1,
  bandwidths                    => 1,
  oral_formants_amplitudes      => 1,
  nasal_formants_amplitudes     => 1,
  tracheal_formants_amplitudes  => 1,
  frication_formants_amplitudes => 1,
  pairs                         => 1,
);
Readonly my %TABLE_TYPES = (
  TableOfReal                   => 1,
  ContingencyTable              => 1,
  Configuration                 => 1,
  Dissimilarity                 => 1,
  Similarity                    => 1,
  Distance                      => 1,
  ScalarProduct                 => 1,
  Weight                        => 1,
  CrossCorrelationTable         => 1,
  CrossCorrelationTables        => 1,
  Diagonalizer                  => 1,
  MixingMatrix                  => 1,
  Confusion                     => 1,
  FeatureWeights                => 1,
  Correlation                   => 1,
  Covariance                    => 1,
  EditCostsTable                => 1,
  SSCP                          => 1,
);
Readonly my %PARTS = (
  TextGrid                      => { tiers=>1,},
  Photo                         => { red=>1,green=>1,blue=>1,transparency=>1,},
  FeatureWeights                => { fweights=>1,},
  vocalTracts                   => { vocalTract=>1,},
  HMM                           => { states=>1,observationSymbols=>1,},
  KNN                           => { input=>1,ouput=>1,},
  KlattGrid                     => { phonation=>1,pitch=>1,flutter=>1,voicingAmplitude=>1,doublePulsing=>1,openPhase=>1,collisionPhase=>1,power1=>1,power2=>1,spectralTilt=>1,aspirationAmplitude=>1,breathinessAmplitude=>1,vocalTract=>1,oral_formants=>1,nasal_formants=>1,nasal_antiformants=>1,coupling=>1,tracheal_formants=>1,tracheal_antiformants=>1,delta_formants=>1,frication=>1,fricationAmplitude=>1,frication_formants=>1,bypass=>1,gain=>1,},
  Manipulation                  => { sound=>1,pulses=>1,pitch=>1,dummyIntensity=>1,duration=>1,dummySpectrogram=>1,dummyFormantTier=>1,dummy1=>1,dummy2=>1,dummy3=>1,dummy10=>1,dummyPitchAnalysis=>1,dummy11=>1,dummy12=>1,dummyIntensityAnalysis=>1,dummyFormantAnalysis=>1,},
);
Readonly my @KEYS = qw/ notHidden leftToRight numberOfStates numberOfObservationSymbols numberOfMixtureComponents componentDimension componentStorage transitionProbs states observationSymbols class name minimumActivity maximumActivity dummyActivitySpreadingRule shunting activityClippingRule spreadingRate activityLeak minimumWeight maximumWeight dummyWeightUpdateRule learningRate instar outstar weightLeak number xmin xmax phonation sound pulses pitch flutter voicingAmplitude doublePulsing openPhase collisionPhase power1 power2 spectralTilt aspirationAmplitude breathinessAmplitude vocalTract oral_formants nasal_formants nasal_antiformants coupling tracheal_formants tracheal_antiformants delta_formants frication fricationAmplitude frication_formants bypass intervals points text nx dx x1 samplingPeriod fmin fmax maximumNumberOfCoefficients maxnCoefficients maxnFormants frames nCoefficients numberOfCoefficients coefficients degree numberOfKnots knots c0 c ymin ymax numberOfNodes nodes numberOfConnections connections nodeFrom nodeTo string1 string2 weight plasticity x y r a gain clamped activity ny dx1 dx2 dy y1 z ceiling maxnCandidates frequency bandwidth strength frame intensity nFormants formant nCandidates candidate tiers size item number value mark nt t fweights numberOfColumns cells columnLabels columnHeaders numberOfRows rows row metric nLayers nUnitsInLayer outputsAreLinear nonLinearityType costFunctionType outputCategories nWeights w string label red green blue transparency voiceLanguageName voiceVariantName wordsPerMinute inputTextFormat inputPhonemeCoding samplingFrequency wordgap pitchAdjustment pitchRange outputPhonemeCoding estimateWordsPerMinute numberOfEigenvalues dimension eigenvalues eigenvectors numberOfObservations labels centroid relativeSize cord lowerCord upperCord shunt velum palate radius tip neutralBodyDistance alveoli teethCavity lowerTeeth upperTeeth lowerLip upperLip nose numberOfMasses length thickness mass k1 Dx Dy Dz weq numberOfStrings strings numberOfElements p min max v vocalTracts formants bandwidths oral_formants_amplitudes nasal_formants_amplitudes tracheal_formants_amplitudes frication_formants_amplitudes pairs nInstances input ouput dummyIntensity duration dummySpectrogram dummyFormantTier dummy1 dummy2 dummy3 dummy10 dummyPitchAnalysis dummy11 dummy12 dummyIntensityAnalysis dummyFormantAnalysis dummy4 dummy5 dummy6 dummy7 dummy8 dummy9 /;
my %setup = ( input => $YAML );
my $TAB = '    ';
my $INDENT;
my $LEVEL = 0;

$setup{'input'} = $JSON if $0 =~ /json/;

GetOptions (
  'yaml'       => sub { },
  'json'       => sub { $setup{'input'} = $JSON },
  'debug'      => \$setup{'debug'},
  'encoding=s' => \$setup{'encoding'},
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
  'tab=s'      => sub {
    shift;
    my $val = shift;
    $TAB = $val if $val =~ /^\s*$/;
  },
  'outfile=s'  => sub {
    shift;
    open OUTPUT, '>', $_[0] or die $!;
    STDOUT->fdopen( \*OUTPUT, 'w' ) or die $!;
  },
) or pod2usage(2);

$INDENT = set_indent();

$setup{'debug'}      = $setup{'debug'}      // 0;
$setup{'input'}      = $setup{'input'}      // $YAML;
$setup{'collection'} = $setup{'collection'} // 0;
$setup{'encoding'}   = $setup{'encoding'}   // 'UTF-8';

foreach (@ARGV) {
  if (-e $_) {
    my $input = read_file($_);
    eval {
      $input = decode($setup{encoding}, $input, Encode::FB_QUIET);
    };
    if ($@) {
      die "Error reading $_.\n $@\n" ;
    }

    $input =~ s/(~|null)/{}/g;

    my $object;
    try {
      $object = Load(encode($setup{encoding}, $input, Encode::FB_CROAK));
    }
    catch {
      warn "Could not parse: $_\n";
      exit 0;
    };

    if ($setup{'debug'}) {
      print Dumper($object) ;
      exit;
    }

    my $size = scalar keys(%{$object});

    if ($size > 1 and !exists $object->{'Object class'}) {
      $object = collectionise($object);
    }

    unless (exists $object->{'Object class'}) {
      warn "Improperly formatted object; cannot deserialize\n";
      exit 0;
    }

    my $class = $object->{'Object class'};
    print "File type = \"ooTextFile\"\n";
    print "Object class = \"$class\"\n\n";
#     delete $object->{'Object class'};
    print_object($class, $object);
  } else {
    die "Can't read file at $_: $!";
  }
}

sub collectionise {
  my $serial = shift;

  my @objects;

  foreach (keys %{$serial}) {
    my $object = $serial->{$_};
    $object->{'name'} = $_;
    $object->{'class'} = $object->{'Object class'};
    delete $object->{'Object class'};
    push @objects, $object;
  }

  return {
    'Object class' => 'Collection',
    'size'         => $#objects + 1,
    'item'         => \@objects
  };
}

sub print_object {
  my $class = shift;
  $class =~ s/^(\S+).*/$1/g;
  my $object = shift;
  die "Not an object: $object" unless ref($object) eq 'HASH';

#   print "Printing $class as object\n";

  my @keys = set_keys($object);

  foreach (@keys) {
    if (!ref($object->{$_})) {
      my $value = $object->{$_} // '';
      if (exists $BOOLEAN{$_}) {
        print_boolean($_, $value);
      } else {
        print $INDENT, "$_ = " . quote_values($_, $value) . " \n";
      }
    } else {
      if (exists $PARTS{$class}->{$_}) {
        if (ref($object->{$_}) eq 'HASH' and scalar keys %{$object->{$_}}) {
          print_part($_, 'exists');
        } else {
          print_part($_, 'absent');
        }
      }
      if (ref($object->{$_}) eq 'HASH') {
        my $class = exists $object->{'Object class'} ?
          $object->{'Object class'} : exists $object->{class} ?
          $object->{class} : $_;
        if ($class eq 'Speaker') {
          print "$_:\n";
          increase_indent();
        }
        print_object($class, $object->{$_});
        if ($class eq 'Speaker') {
          decrease_indent();
        }
      } elsif (ref($object->{$_}) eq 'ARRAY') {
        if (exists $TABLE_TYPES{$class}) {
          if ($_ eq "columnLabels") {
            print_tabbed_list($_, $object->{$_});
          } elsif ($_ eq "rows") {
            foreach my $i (0..@{$object->{$_}}-1) {
              my $row = $object->{$_}->[$i];
              while ((my $key, my $value) = each %{$row}) {
                print "row [" . ($i+1) . "]: ";
                print_tabbed_list($key, $value);
              }
            }
          } else {
            print_list($_, $object->{$_});
          }
        } else {
          print_list($_, $object->{$_});
        }
      }
    }
  }
}

sub quote_values {
  my $key = shift;
  my @return;

  if (exists $STRINGS{$key}) {
    foreach my $string (@_) {
      $string =~ s/"/""/g;
      push @return, '"' . $string . '"';
    }
  } else {
    @return = @_;
  }
  wantarray() ? return @return : return $return[0];
}

sub print_part {
  my $key = shift;
  my $value = shift;

  print $INDENT, "$key? <$value> \n";
}

sub print_boolean {
  my $key = shift;
  my $value = shift;

  $value = 'true'  if ($value eq '1');
  $value = 'false' if ($value eq '');

  print $INDENT, "$key = <$value> \n";
}

sub print_tabbed_list {
  my $name = shift;
  my $list = shift;

  my @list = quote_values($name, @{$list});
  if ($name eq "columnLabels") {
    print "$name []:\n" . join("\t", @list) . "\n";
  } else {
    print join("\t", ("\"$name\"", @list)) . "\n";
  }
}

# Print a list following the rules of Praat object serialisation
sub print_list {
  my $name  = shift;
  my $list = shift;
  die "Not a list: $list" unless ref($list) eq 'ARRAY';

#   print "Printing $name as list\n";

  if (ref($list->[0]) eq 'ARRAY') {
    # Multimensional arrays are printed differently in Praat
    print $INDENT, "$_ [] []: \n";
    increase_indent();
    foreach my $x (1..@{$list}) {
      print $INDENT, "$name [$x]:\n";
      increase_indent();
      foreach my $y (1..@{$list->[$x-1]}) {
        my $value = quote_values($name, $list->[$x-1]->[$y-1]);
        print $INDENT, "$name [$x] [$y] = " . $value . " \n";
      }
      decrease_indent();
    }
    decrease_indent();

  } else {
    if (exists $SIZED_LISTS{$name}) {
      print $INDENT, "$name: size = " . scalar @{$list} . " \n";
    } else {
      print $INDENT, "$_ []: \n";
      increase_indent();
    }
    foreach my $i (1..@{$list}) {
      if (ref($list->[$i-1])) {
        print $INDENT, $name, ' [', $i, "]:\n";
        increase_indent();
        my $class = exists $list->[$i-1]->{'Object class'} ?
            $list->[$i-1]->{'Object class'} : exists $list->[$i-1]->{class} ?
            $list->[$i-1]->{class} : $name;
        print_object($class, $list->[$i-1]);
        decrease_indent();
      } else {
        my $value = quote_values($name, $list->[$i-1]);
        if ($name eq 'weq') {
          # The weq list in the Speaker object is _the only_ list that seems
          # to be zero-based.
          print $INDENT, "$name [" . ($i-1) . "] = " . $value . " \n";
        } else {
          print $INDENT, "$name [$i] = " . $value . " \n";
        }
      }
    }
    decrease_indent() if (!exists $SIZED_LISTS{$name});
  }
}

# Increase indent level
sub increase_indent {
  $LEVEL++;
  $INDENT = set_indent();
}

# Decrease indent level
sub decrease_indent {
  $LEVEL-- if ($LEVEL > 0);
  $INDENT = set_indent();
}

# Upadte state of indentation
sub set_indent {
  return $TAB x $LEVEL;
}

# Praat requires keys to be in a precise order. This sub makes sure the known
# keys match the known order in which they should appear.
sub set_keys {
  my $object = shift;
  die "Not an object: $object" unless ref($object) eq 'HASH';

  my %object = %{$object};
  my @keys;
  foreach (@KEYS) {
    if (exists $object{$_}) {
      push @keys, $_;
      delete $object{$_};
    } else {
    }
  }
#   print Dumper \@keys;
  return @keys;

#   return @keys, keys(%object);
}

__END__

=head1 NAME

yaml2praat, json2praat - De-serialise YAML or JSON to Praat objects

=head1 SYNOPSIS

 yaml2praat [options] [file ...]
 json2praat [options] [file ...]

Options:

    -yaml         Use YAML serialisation
    -json         Use JSON serialisation
    -tab=TAB      Specify character(s) to be used for indentation
    -encoding     Specify encoding of input file.

=head1 DESCRIPTION

This script takes a serialised representation of a Praat object in either JSON
or YAML and returns a version of the same data structure suitable to be read by
Praat. If the input format is not specified, YAML is assumed by default.

Groups of Praat objects can be serialised as either a Praat-specific
I<Collection> object, or following the standard serialisation patterns in either
YAML or JSON. This script correctly manages both kinds, ensuring the output can
be read as-is in Praat (at least until a bug is found).

The script can be called as B<yaml2praat> or as B<json2praat>. The only
difference is that in the latter case, the I<-json> option is set by default.

=head1 OPTIONS

=over 8

=item B<-yaml>

Read serial data from YAML.

=item B<-json>

Read serial data from JSON.

=item B<-tab=TAB>

Specify character or series of characters to be used for each indent level. The
characters provided need to match /^\s*$/, or they will be ignored. Default
value is a series of four spaces ("    ").

=item B<-encoding=CODE>

Specify the encoding of the input file. This script uses B<Encode> in the
background, so the file's I<CODE> can be any of the ones supported by that Perl
module. For a complete list, see

http://search.cpan.org/~jhi/perl-5.8.1/ext/Encode/lib/Encode/Supported.pod

If unspecified, the script defaults to reading as UTF-8. Output is always UTF-8.

=back

=head1 SEE ALSO

praat2yaml(1), praat2json(1)

=cut
