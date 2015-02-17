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

use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;
use File::Slurp;
use Readonly;
use Pod::Usage;
use Encode qw(encode decode);

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';
Readonly my %STRINGS = (
  class             => 1,
  name              => 1,
  text              => 1,
  label             => 1,
  string            => 1,
  mark              => 1,
  columnLabels      => 1,
  voiceVariantName  => 1,
  voiceLanguageName => 1,
);
Readonly my @KEYS = qw/class name xmin xmax intervals points text nx dx x1 ymin
  ymax ny dy y1 z ceiling maxnCandidates frequency strength frame intensity
  nCandidates candidate tiers size item number mark nt t numberOfColumns cells
  columnLabels columnHeaders numberOfRows rows row metric w string label red
  green blue transparency voiceLanguageName voiceVariantName wordsPerMinute
  inputTextFormat inputPhonemeCoding samplingFrequency wordgap pitchAdjustment
  pitchRange outputPhonemeCoding estimateWordsPerMinute/;

my %setup;
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
    die("Error reading $_.\nAre you using the right encoding?") if $input eq "";

    my $object;
    if ($setup{'input'} eq $JSON) {
      use JSON qw//;
      $object = JSON->decode_json($input);
      
      if ($setup{'debug'}) {
        print Dumper($object);
        exit;
      }
    } else {
      use YAML::XS;
      $object = Load($input);
      
      if ($setup{'debug'}) {
        print Dumper($object) ;
        exit;
      }
    }
    
    my $size = scalar keys(%{$object});

    if ($size > 1 and !exists $object->{'Object class'}) {
      $object = collectionise($object);
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
  my $object = shift;
  die "Not an object: $object" unless ref($object) eq 'HASH';

  my @keys = set_keys($object);

  foreach (@keys) {
    if (!ref($object->{$_})) {
      my $value = $object->{$_};
      $value = stringify($_, $value);
      if ($_ eq 'tiers' and $value =~ /(true|false)/) {
        $value = $value eq 'true' ? 'exists' : 'none?';
        print $INDENT, "$_? <$value> \n";
      } else {
        print $INDENT, "$_ = $value \n";
      }
    } else {
      if ($_ =~ /^(red|green|blue|transparency)$/) {
        print $INDENT, "$_? <exists> \n";
      }
      if (ref($object->{$_}) eq 'HASH') {
        my $class = exists $object->{'Object class'} ?
          $object->{'Object class'} : exists $object->{class} ?
          $object->{class} : $_;
        print_object($class, $object->{$_});
      } elsif (ref($object->{$_}) eq 'ARRAY') {
        if ($class =~ /(TableOfReal|ContingencyTable|Configuration|(Diss|S)imilarity|Distance|ScalarProduct|Weight)/) {
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

# Check a key-value pair to see if the key corresponds to a known list of
# keys whose values are strings. If so, return value between quotation marks.
sub stringify {
  my $key = shift;
  
  if (exists $STRINGS{$key}) {
    # Praat escapes string-internal double-quotes as ""
    my @return;
    foreach my $string (@_) {
      $string =~ s/"/""/g;
      push @return, '"' . $string . '"';
    }
    wantarray() ? return @return : return $return[0];
  } else {
    wantarray() ? return @_ : return $_[0];
  }
}

sub print_tabbed_list {
  my $name = shift;
  my $list = shift;
  
  my @list = stringify($name, @{$list});
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

  if (ref($list->[0]) eq 'ARRAY') {
    # Multimensional arrays are printed differently in Praat
    print $INDENT, "$_ [] []: \n";
    increase_indent();
    foreach my $x (1..@{$list}) {
      print $INDENT, "$name [$x]:\n";
      increase_indent();
      foreach my $y (1..@{$list->[$x-1]}) {
        print $INDENT, "$name [$x] [$y] = " . $list->[$x-1]->[$y-1] . " \n";
      }
      decrease_indent();
    }
    decrease_indent();

  } else {
    my $size_array = '^(intervals|points)$';
    if ($name =~ /$size_array/) {
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
        print $INDENT, "$name [$i] = " . $list->[$i-1] . " \n";
      }
    }
    decrease_indent() if ($name !~ /$size_array/);

  }
}

# Increase indent level
sub increase_indent {
  $LEVEL++;
  $INDENT = set_indent();
}

# Decrease indent level
sub decrease_indent {
  $LEVEL--;
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
