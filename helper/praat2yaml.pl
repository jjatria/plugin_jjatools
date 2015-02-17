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

use Readonly;
use Pod::Usage;
use Data::Dumper;
use File::Slurp;
use YAML::XS;
use Encode qw(encode decode);

use Getopt::Long qw(:config no_ignore_case);

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';
Readonly my $TAB    => '    ';

my %setup;

$setup{'output'} = $JSON if $0 =~ /json/;

GetOptions (
  'yaml'       => sub { },
  'json'       => sub { $setup{'output'} = $JSON },
  'pretty'     => sub { $setup{'format'} = $PRETTY },
  'minified'   => sub { $setup{'format'} = $MINI },
  'debug'      => \$setup{'debug'},
  'encoding=s' => \$setup{'encoding'},
  'collection' => \$setup{'collection'},
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
) or pod2usage(2);

$setup{'debug'}      = $setup{'debug'} // 0;
$setup{'collection'} = $setup{'collection'} // 0;
$setup{'output'}     = $setup{'output'}     // $YAML;
$setup{'encoding'}   = $setup{'encoding'}   // 'UTF-8';
$setup{'format'}     = $PRETTY unless exists $setup{'format'};

foreach (@ARGV) {
  if (-e $_) {
    my $input = read_file($ARGV[0]);
    eval {
      $input = decode($setup{encoding}, $input, Encode::FB_WARN);
    };
    die("Error reading $_.\nAre you using the right encoding?") if $input eq "";

    # Praat Photo objects are saved in (yet another) slightly non-standard
    # way. If a Photo object is contained in the stream to be processed, then
    # some pre-processing is needed.
    $input = photo_fix($input) if ($input =~ /class = "Photo"/);
    
    $input = tableofreal_fix($input) if ($input =~ /class = "(TableOfReal|ContingencyTable|Configuration|(Diss|S)imilarity|Distance|ScalarProduct|Weight)"/);

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
    my $object = Load($input);

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
  print Dump $o;
}

sub to_json {
  my $o = shift;
  use JSON qw//;
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
  $input =~ s/\\/\\\\/g;
  
  my @lines = split "\n", $input;
  foreach my $i (1..$#lines) {
    if ($lines[$i] =~ /([^"]*")(.*)("$)/) {
      my $start = $1;
      my $string = $2;
      my $end = $3;
      $string =~ s/""/\\"/g;
      $lines[$i] = $start . $string . $end;
    }
  }
  return join("\n", @lines) . "\n";
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

sub tableofreal_fix {
  my $input = shift;
  my @lines = split "\n", $input;

  my $in_tor = 0;
  my $in_rows = 0;
  foreach my $i (0..$#lines) {
    my $indent;
    if ($lines[$i] =~ /^(\s*)(Object )?class = "(TableOfReal|ContingencyTable|Configuration|(Diss|S)imilarity|Distance|ScalarProduct|Weight)"/) {
      $in_tor = 1;
      $indent = $1;
    } elsif ($lines[$i] =~ /^\s*item \[[0-9]+\]:\s*/) {
      $in_tor  = 0;
      $in_rows = 0;
    }

    if ($in_tor and $lines[$i] =~ "columnLabels") {
      $lines[$i+1] = "$TAB- " . $lines[$i+1];
      $lines[$i+1] =~ s/\t([^\t]+)/\n$TAB- $1/g;
    }
    
    if ($in_tor and $lines[$i] =~ /numberOfRows/) {
      $in_rows = 1;
      $lines[$i] .= "\nrows:\n";
      next;
    }

    if ($in_tor and $in_rows) {
      if ($lines[$i] !~ /^row/) {
        $in_rows = 0;
      } else {
        $lines[$i] =~ s/\t/: [ /;
        $lines[$i] =~ s/\t/, /g;
        $lines[$i] .= " ]";
      }
    }
  }
  return join("\n", @lines);
}

sub photo_fix {
  my $input = shift;
  my @lines = split "\n", $input;

  my $in_photo = 0;
  my $fix_line = 0;
  foreach my $i (0..$#lines) {
    my $indent;
    if ($lines[$i] =~ /^(\s*)(Object )?class = "Photo"/) {
      $in_photo = 1;
      $indent = $1;
    } elsif ($lines[$i] =~ /^\s*item \[[0-9]+\]:\s*/) {
      $in_photo = 0;
    }

    if ($in_photo and $lines[$i] =~ /^(\s*(red|green|blue|transparency))\? <exists>\s*$/) {
      $fix_line = 1;
      $lines[$i] = "$1:";
      next;
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

    -yaml         Use YAML serialisation
    -json         Use JSON serialisation
    -pretty       Pretty print output (only used with JSON)
    -mini         Minify output (only used with JSON)
    -encoding     Specify encoding of input file.
    -collection   Maintain Praat Collection structure
    -debug        Only process data with regular expressions, and print

=head1 OPTIONS

=over 8

=item B<-yaml>

Use YAML for serialisation

=item B<-json>

Use JSON for serialisation

=item B<-pretty>

Pretty print output (this option is only used with JSON).

=item B<-mini>

Minify output (this option is only used with JSON).

=item B<-encoding=CODE>

Specify the encoding of the input file. This script uses B<Encode> in the
background, so the file's I<CODE> can be any of the ones supported by that Perl
module. For a complete list, see

http://search.cpan.org/~jhi/perl-5.8.1/ext/Encode/lib/Encode/Supported.pod

If unspecified, the script defaults to reading as UTF-8. Output is always UTF-8.

=item B<-collection>

Preserve Praat's I<Collection> data structure.

Praat has its own way to serialise collections of objects, as a single
I<Collection> object. Since both I<YAML> and I<JSON> are made for serial data
formats, this script defaults to the standard way to serialise data in those
formats. This behaviour changes when this flag is set.

=item B<-debug>

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
