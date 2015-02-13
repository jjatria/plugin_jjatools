#!/usr/bin/perl

# Data serialisation script for Praat
#
# Written by Jose J. Atria (February 12, 2015)
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
use YAML::Tiny;
use Encode qw(encode decode);

use Getopt::Long qw(:config no_ignore_case);

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';

my %setup;

$setup{'output'} = $JSON if $0 =~ /json/;

GetOptions (
  'yaml'       => sub { },
  'json'       => sub { $setup{'output'} = $JSON },
  'pretty'     => sub { $setup{'format'} = $PRETTY },
  'minified'   => sub { $setup{'format'} = $MINI },
  'encoding=s' => \$setup{'encoding'},
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
) or pod2usage(2);

$setup{'output'}   = $setup{output} // $YAML;
$setup{'encoding'} = $setup{'encoding'} // 'UTF-8';
$setup{'format'}   = $PRETTY unless exists $setup{'format'};

foreach (@ARGV) {
  if (-e $_) {
    my $input = read_file($ARGV[0]);
    eval {
      $input = decode($setup{encoding}, $input, Encode::FB_QUIET);
    };
    die("Error reading $_.\nAre you using the right encoding?") if $input eq "";
    
    # The Praat output format can be converted to satisfactory YAML by means of
    # the following set of regular expressions.
    $input = yaml_regex($input);

    # To be sure, however, the file is then parsed as YAML anyway, to catch any
    # remaining errors.
    my $object = YAML::Tiny->read_string($input);

    if ($setup{output} eq $JSON) {
      to_json($object);
    } elsif ($setup{output} eq $YAML) {
      to_yaml($object);
    }
  } else {
    die "Can't read file at $_: $!";
  }
}

sub yaml_regex {
  my $input = shift;
  $input =~ s/File type = "ooTextFile"\n//g;
  $input =~ s/(Object class) = "([^"]+)"/$1: $2/g;
  $input =~ s/\s*\n/\n/g;
  $input =~ s/(\S+)\? /$1: /g;
  $input =~ s/<exists>\s*?/true/g;
  $input =~ s/(\S+) = (\S*)/$1: $2/g;
  $input =~ s/(\S+): size: [0-9]+/$1:/g;
  $input =~ s/(\S+) \[\](?: \[\])?:/$1:/g;
  $input =~ s/(\S+) \[[0-9]+\]( \[[0-9]+\])?:/-/g;
  return $input;
}

sub to_yaml {
  my $o = shift;
  print encode('UTF-8', $o->write_string());
}

sub to_json {
  my $o = shift;
  use JSON qw//;
  my $json = JSON->new->allow_nonref;
  my $output;
  if ($setup{format} eq $PRETTY) {
    $output = $json->pretty->encode($o->[0]);
  } else {
    $output = $json->encode($o->[0]);
  }
  print encode('UTF-8', $output);
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
