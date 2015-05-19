#!/usr/bin/perl

# Data serialisation script for Praat
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
    'use File::Slurp',
    'use Pod::Usage',
    'use Getopt::Long qw(:config no_ignore_case)',
    'use Encode qw(encode decode)',
    'use YAML::XS',
    'use JSON qw//',
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
    exit 1;
  }
}

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';
Readonly my $TAB    => '    ';
Readonly my %TYPES = (
  TableOfReal         => '(TableOfReal|ContingencyTable|Configuration|(Diss|S)imilarity|Distance|ScalarProduct|Weight|CrossCorrelationTables?|Diagonalizer|MixingMatrix|Confusion|FeatureWeights|Correlation|Covariance|EditCostsTable|SSCP)',
  size_list           => '(intervals|points|outputCategories)',
  MultiPart           => '(Photo|KlattGrid|VocalTractTier|TextGrid|FeatureWeights|HMM|KNN|Manipulation)',
  FeatureWeightsParts => '(fweights)',
  PhotoParts          => '(red|green|blue|transparency)',
  TextGridParts       => '(tiers)',
  KlattGridParts      => '(phonation|pitch|flutter|voicingAmplitude|doublePulsing|openPhase|collisionPhase|power1|power2|spectralTilt|aspirationAmplitude|breathinessAmplitude|vocalTract|oral_formants|nasal_(anti)?formants|coupling|tracheal_(anti)?formants|delta_formants|frication(Amplitude|_formants)?|bypass|gain)',
  VocalTractTierParts => '(vocalTract)',
  HMMParts            => '(states|observationSymbols)',
  KNNParts            => '(input|ouput)',
  ManipulationParts   => '(sound|pulses|pitch|dummyIntensity|duration|dummySpectrogram|dummyFormantTier|dummy1|dummy2|dummy3|dummy10|dummyPitchAnalysis|dummy11|dummy12|dummyIntensityAnalysis|dummyFormantAnalysis)',
);

my %setup;

$setup{'output'} = $JSON if $0 =~ /json/;


GetOptions (
  \%setup,
  'yaml'       => sub {},
  'json'       => sub { $setup{'output'} = $JSON },
  'pretty'     => sub { $setup{'format'} = $PRETTY },
  'minified'   => sub { $setup{'format'} = $MINI },
  'debug',
  'encoding=s',
  'collection',
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
  'outfile=s'  => sub {
    shift;
    open OUTPUT, '>', $_[0] or die $!;
    STDOUT->fdopen( \*OUTPUT, 'w' ) or die $!;
  },
) or pod2usage(2);

$setup{'debug'}      = $setup{'debug'} // 0;
$setup{'collection'} = $setup{'collection'} // 0;
$setup{'output'}     = $setup{'output'}     // $YAML;
$setup{'encoding'}   = $setup{'encoding'}   // 'UTF-8';
$setup{'format'}     = $PRETTY unless exists $setup{'format'};

foreach (@ARGV) {
  if (-e $_) {
    my $input = read_file($ARGV[0]) ;
    eval {
      $input = decode($setup{encoding}, $input, Encode::FB_WARN);
    };
    die("Error reading $_.\nAre you using the right encoding?") if $@;

    # Praat Photo objects are saved in (yet another) slightly non-standard
    # way. If a Photo object is contained in the stream to be processed, then
    # some pre-processing is needed.

    $input = tableofreal_fix($input) if ($input =~ /class = "$TYPES{TableOfReal}"/);
# 
    $input = multipart_fix($input) if ($input =~ /class = "$TYPES{MultiPart}.*"/);

    $input = polygon_fix($input) if ($input =~ /class = "Polygon.*"/);

    # The Praat output format can be converted to satisfactory YAML by means of
    # the following set of regular expressions.
    $input = yaml_regex($input);

    # For debugging purposes, print the input file before YAML parsing.
    # Does the data need any further pre-processing before proper parsing?
    if ($setup{'debug'}) {
      print $input;
      exit;
    }

    # To be sure, however, the file is then parsed as YAML anyway, to catch any
    # remaining errors.
    my $object = Load(encode($setup{encoding}, $input, Encode::FB_CROAK));

    if ($object->{'Object class'} eq "Collection" and
        !$setup{'collection'}) {
      $object = decollectionise($object);
    }

    if ($setup{output} eq $JSON) {
      to_json($object);
    } elsif ($setup{output} eq $YAML) {
      to_yaml($object);
    }
  } else {
    die "Can't read file at $_: $!";
  }
}

sub to_yaml {
  my $o = shift;

  print decode('UTF-8', Dump $o);
}

sub to_json {
  my $o = shift;

  my $json = JSON->new->allow_nonref;
  my $output;
  if ($setup{format} eq $PRETTY) {
    $output = $json->pretty->encode($o);
  } else {
    $output = $json->encode($o);
  }

  print $output;
}

sub yaml_regex {
  my $input = shift;

  my @lines = split "\n", $input;
  foreach my $i (1..$#lines) {
    if ($lines[$i] =~ /([^"]*")(.*)("$)/) {
      my $start = $1;
      my $string = $2;
      my $end = $3;
      $string =~ s/""/\\"/g;
      $lines[$i] = $start . $string . $end;
    } elsif ($i > 1 and $lines[$i] =~ /(?'indent'^\s*)(?'name'\w+) \[1\](:\s?| = .*)$/) {
      if ($+{name} !~ /(weq|nUnitsInLayer)/ and $lines[$i-1] !~ /^\s*$+{name}( \[\]:\s?|: size.*)$/) {
        $lines[$i] = $+{indent} . $+{name} . " []: \n" . $lines[$i];
      }
    }
  }
  $input = join("\n", @lines) . "\n";

  $input =~ s/File type = "ooTextFile"\n//g;
  $input =~ s/(Object class) = "([^"]+)"/$1: $2/g;
  $input =~ s/\s*\n/\n/g;
  $input =~ s/(\S+)\? /$1: /g;
  $input =~ s/<exists>\s*?/true/g;
  $input =~ s/(\S+) = (\S*)/$1: $2/g;
  $input =~ s/(\S+): size: 0/$1: []/g;
  $input =~ s/(\S+): size: [0-9]+/$1:/g;
  $input =~ s/(\S+) \[\](?: \[\])?:/$1:/g;
  $input =~ s/(\S+) \[[0-9]+\]( \[[0-9]+\])?:/-/g;
  $input =~ s/<(true|false)>/$1/g;
  $input =~ s/\\/\\\\/g;

  return $input;
}

sub decollectionise {
  my $original = shift;

  my %names;
  foreach (@{$original->{'item'}}) {
    if (exists $names{$_->{'name'}}) {
      warn "W: Some object names repeated; falling back to Collection";
      return $original;
    } else {
      $names{$_->{'name'}} = 1;
    }
  }

  my %objects;
  foreach (@{$original->{'item'}}) {
    $_->{'Object class'} = $_->{'class'};
    $objects{$_->{'name'}} = $_;
    delete $_->{'class'};
    delete $_->{'name'};
  }
  return \%objects;
}

sub polygon_fix {
  my $input = shift;
  $input =~ s/
    \n(?'tab'\s*)
    x\ \[(?:(?'index'[0-9]+))\]
    (?'line'.*\n)
    y\ \[(?:[0-9]+)\]
    /\npoints\ [$+{index}]:\ \n$+{tab}${TAB}x$+{line}$+{tab}${TAB}y/xg;
  return $input;
}

sub tableofreal_fix {
  my $input = shift;
  my @lines = split "\n", $input;

  my $in_tor = 0;
  my $in_rows = 0;
  my $indent = '';
  foreach my $i (0..$#lines) {
    if ($lines[$i] =~ /^(\s*)(?:Object )?class.*($TYPES{TableOfReal})"/) {
      $in_tor = 1;
      $indent = $1;
    } elsif ($lines[$i] =~ /fweights\s*/) {
      $in_tor  = 1;
      $indent = '    ';
    } elsif ($lines[$i] =~ /^\s*item \[[0-9]+\]:\s*/) {
      $in_tor  = 0;
      $in_rows = 0;
    }

    if ($in_tor and $lines[$i] =~ /(^\s*)columnLabels/) {
      $lines[$i] = $indent . $lines[$i] if ($input =~ /CrossCorrelationTables?/);
      $lines[$i+1] =~ s/^\s*//g;
      $lines[$i+1] = "$indent- " . $lines[$i+1];
      $lines[$i+1] =~ s/\t(?:\s*)([^\t]+)/\n$indent- $1/g;
    }

    if ($in_tor and $lines[$i] =~ /(^\s*)numberOfRows/) {
      $in_rows = 1;
      $lines[$i] .= "\n$1rows:\n";
      next;
    }

    if ($in_tor and $in_rows) {
      if ($lines[$i] =~ /(^\s*)row/) {
        $lines[$i] = $indent . $lines[$i];
        $lines[$i] =~ s/\t/: [ /;
        $lines[$i] =~ s/\t/, /g;
        $lines[$i] .= " ]";
      } else {
        $in_rows = 0;
      }
    }
  }
  return join("\n", @lines);
}

sub multipart_fix {
#   print "Multipart!\n";
  my $input = shift;
  my @lines = split "\n", $input;

  my $in_multipart = 0;
  my $class = "";
  my $fix_line = 0;
  foreach my $i (0..$#lines) {
    my $indent = "";
    if ($lines[$i] =~ /^(\s*)(?:Object )?class = "(?'class'$TYPES{MultiPart}).*"/) {
      $in_multipart = 1;
      $class = $+{class};
      $indent = $1;
    } elsif (($lines[$i] =~ /^\s*item \[[0-9]+\]:\s*/) || ($lines[$i] =~ /^\s*class =/)) {
      $in_multipart = 0;
      $fix_line = 0;
    }

    if ($in_multipart) {
      if ($lines[$i] =~ /^(\s*$TYPES{$class . 'Parts'})\? <exists>\s*$/) {
        $fix_line = 1;
        $lines[$i] = "$1:";
        next;
      } elsif ($lines[$i] =~ /^(\s*$TYPES{$class . 'Parts'})\? <absent>\s*$/) {
        $lines[$i] = "$1: ~";
        $fix_line = 0;
        next;
      }
    }
    $lines[$i] = '    ' . $lines[$i] if ($fix_line);
  }
  return (join "\n", @lines);
}

__END__

=head1 NAME

praat2yaml, praat2json - Serialise Praat objects from text

=head1 SYNOPSIS

 praat2yaml [options] [file ...]
 praat2json [options] [file ...]

Options:

    --yaml         Use YAML serialisation
    --json         Use JSON serialisation
    --pretty       Pretty print output (only used with JSON)
    --mini         Minify output (only used with JSON)
    --encoding     Specify encoding of input file.
    --collection   Maintain Praat Collection structure
    --debug        Only process data with regular expressions, and print
    --help         Show the full documentation

=head1 OPTIONS

=over 8

=item B<--yaml>

Use YAML for serialisation

=item B<--json>

Use JSON for serialisation

=item B<--pretty>

Pretty print output (this option is only used with JSON).

=item B<--mini>

Minify output (this option is only used with JSON).

=item B<--encoding=CODE>

Specify the encoding of the input file. This script uses B<Encode> in the
background, so the file's I<CODE> can be any of the ones supported by that Perl
module. For a complete list, see

http://search.cpan.org/~jhi/perl-5.8.1/ext/Encode/lib/Encode/Supported.pod

If unspecified, the script defaults to reading as UTF-8. Output is always UTF-8.

=item B<--collection>

Preserve Praat's I<Collection> data structure.

Praat has its own way to serialise collections of objects, as a single
I<Collection> object. Since both I<YAML> and I<JSON> are made for serial data
formats, this script defaults to the standard way to serialise data in those
formats. This behaviour changes when this flag is set.

=item B<--help>

Show this documentaion.

=item B<--debug>

The processing of Praat files is separated into two stages: one of
pre-processing, during which the format is converted to YAML to a satisfactory
degree by means of regular expressions and some simple text editing.

To ensure the completeness of this conversion, the pre-processed stream is then
parsed as a YAML object, and any further processing (such as conversion to
JSON, etc) are performed on this parsed object.

Setting this flag will output the result of the pre-processing stage, for
debugging purposes.

=back

=head1 DESCRIPTION

This script takes a text representation of a Praat object, and returns a
serialised version of the same data structure. Output can optionally be given
using the JSON or YAML serialisation schemes, the latter being the default.

The script can be called as B<praat2yaml> or as B<praat2json>. The only
difference is that in the latter case, the I<-json> option is set by default.

=head1 SEE ALSO

yaml2praat(1), json2praat(1)

=cut
