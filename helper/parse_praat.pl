#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

use Getopt::Long qw(:config no_ignore_case);

my %setup;
GetOptions (
  \%setup,
  'yaml',
  'json',
  'pretty',
  'minified',
);

use Data::Dumper;
use File::Slurp;
use YAML::Tiny;

my $input = read_file($ARGV[0]);

$input =~ s/File type = "ooTextFile"\n//g;
$input =~ s/Object (class) = "(\S+)( ([0-9]+))?"/$1: $2/g;

$input =~ s/\s*\n/\n/g;
$input =~ s/(\S+)\? /$1: /g;
$input =~ s/<exists> /true/g;
$input =~ s/(\S+) = (\S*)/$1: $2/g;
$input =~ s/(\S+): size: [0-9]+/$1:/g;
$input =~ s/(\S+) \[\]:/$1:/g;
$input =~ s/(\S+) \[[0-9]+\]:/-/g;

my $object = YAML::Tiny->read_string($input);

if (exists $setup{yaml}) {
  to_yaml($object);
} elsif (exists $setup{json}) {
  to_json($object);
}

sub to_yaml {
  my $o = shift;
  print $o->write_string();
}

sub to_json {
  my $o = shift;
  use JSON;
  my $json = JSON->new->allow_nonref;
  if (exists $setup{pretty}) {
    print $json->pretty->encode($o->[0]);
  } else {
    print $json->encode($o->[0]);
  }
}
