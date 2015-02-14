#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

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

my %setup;
my $TAB = '    ';
my $INDENT;
my $LEVEL = 0;

$setup{'input'} = $JSON if $0 =~ /json/;

GetOptions (
  'yaml'       => sub { },
  'json'       => sub { $setup{'input'} = $JSON },
  'encoding=s' => \$setup{'encoding'},
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
  'tab=s'      => sub {
    shift;
    my $val = shift;
    $TAB = $val if $val =~ /^\s*$/;
  },
) or pod2usage(2);

$INDENT = set_indent();

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
      use JSON;
      $object = decode_json($input);
    } else {
      use YAML::Tiny;
      $object = YAML::Tiny->read_string($input);
      $object = $object->[0];
    }

    my $size = scalar keys(%{$object});

    if ($size > 1 and !exists $object->{'Object class'}) {
      $object = collectionise($object);
    }

    my $class = $object->{'Object class'};
    print "File type = \"ooTextFile\"\n";
    print "Object class = \"$class\"\n\n";
    print_object($object);
  } else {
    die "Can't read file at $_: $!";
  }
}

sub collectionise {
  my $serial = shift;
  print "Collectionise\n";

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
  my $object = shift;
  die "Not an object: $object" unless ref($object) eq 'HASH';

  my @keys = set_keys($object);

  foreach (@keys) {
    if (!ref($object->{$_})) {
      my $value = $object->{$_};
      if ($_ eq "tiers" and $value =~ /^<.*?>$/) {
        print $INDENT, "$_? = $value \n";
      } else {
        $value = stringify($_, $value);
        if ($_ eq 'tiers' and $value =~ /(true|false)/) {
          $value = $value eq 'true' ? 'exists' : 'none?';
          print $INDENT, "$_? <$value> \n";
        } else {
          print $INDENT, "$_ = $value \n";
        }
      }
    }
  }

  foreach (@keys) {
    if (ref($object->{$_}) eq 'HASH') {
      print_object($object->{$_});
    } elsif (ref($object->{$_}) eq 'ARRAY') {
      print_list($_, $object->{$_});
    }
  }
}

# Check a key-value pair to see if the key corresponds to a known list of
# keys whose values are strings. If so, return value between quotation marks.
sub stringify {
  my $key = shift;
  my $val = shift;

  my %strings = (
    class  => 1,
    name   => 1,
    text   => 1,
    label  => 1,
    string => 1,
    mark   => 1,
  );

  if (exists $strings{$key}) {
    return '"' . $val . '"';
  } else {
    return $val;
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
    if ($name =~ /^(intervals|points)$/) {
      print $INDENT, "$name: size = " . scalar @{$list} . " \n";
    } else {
      print $INDENT, "$_ []: \n";
      increase_indent();
    }
    foreach my $i (1..@{$list}) {
      if (ref($list->[$i-1])) {
        print $INDENT, $name, ' [', $i, "]:\n";
        increase_indent();
        print_object($list->[$i-1]);
        decrease_indent();
      } else {
        print $INDENT, "$name [$i] = " . $list->[$i-1] . " \n";
      }
    }
    decrease_indent() if ($name !~ /^(intervals|points)$/);

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

  my $copy = $object;
  my @keys = ();
  # Many objects, including items in Collections
  if (exists $object->{'class'}) {
    push @keys, ('class');
  }
  # Many objects, including items in Collections
  if (exists $object->{'name'}) {
    push @keys, ('name');
  }
  # Many time-series-like objects
  if (exists $object->{'xmin'}) {
    push @keys, ('xmin', 'xmax');
  }
  # IntervalTiers
  if (exists $object->{'intervals'}) {
    push @keys, ('intervals');
  }
  # TextTiers
  if (exists $object->{'points'}) {
    push @keys, ('points');
  }
  # TextGrid intervals
  if (exists $object->{'text'}) {
    push @keys, ('text');
  }
  # Sampled matrix-like objects
  if (exists $object->{'nx'}) {
    push @keys, ('nx', 'dx', 'x1');
  }
  # Multi-dimensional arrays (Intensity, Sound, etc)
  if (exists $object->{'ymin'}) {
    push @keys, ('ymin', 'ymax');
  }
  # Multi-dimensional arrays (Intensity, Sound, etc)
  if (exists $object->{'ny'}) {
    push @keys, ('ny', 'dy', 'y1');
  }
  # Multi-dimensional arrays (Intensity, Sound, etc)
  if (exists $object->{'z'}) {
    push @keys, ('z');
  }
  # Pitch
  if (exists $object->{'ceiling'}) {
    push @keys, ('ceiling');
  }
  # Pitch
  if (exists $object->{'maxnCandidates'}) {
    push @keys, ('maxnCandidates');
  }
  # Pitch candidate
  if (exists $object->{'frequency'}) {
    push @keys, ('frequency', 'strength');
  }
  # Pitch
  if (exists $object->{'frame'}) {
    push @keys, ('frame');
  }
  # Pitch frames
  if (exists $object->{'nCandidates'}) {
    push @keys, ('intensity', 'nCandidates', 'candidate');
  }
  # TextGrids
  if (exists $object->{'tiers'}) {
    push @keys, ('tiers');
  }
  if (exists $object->{'size'}) {
    push @keys, ('size', 'item');
  }
  # TextTiers
  if (exists $object->{'mark'}) {
    push @keys, ('number', 'mark');
  }
  # PointProcess
  if (exists $object->{'t'}) {
    push @keys, ('nt', 't');
  }
  # Tables
  if (exists $object->{'numberOfColumns'}) {
    push @keys, ('numberOfColumns');
  }
  # Tables
  if (exists $object->{'cells'}) {
    push @keys, ('cells');
  }
  # Tables
  if (exists $object->{'columnHeaders'}) {
    push @keys, ('columnHeaders', 'rows');
  }
  # Table cell
  if (exists $object->{'string'}) {
    push @keys, ('string');
  }
  # Table cell
  if (exists $object->{'label'}) {
    push @keys, ('label');
  }

  return @keys;
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
