#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

# Tested objects:
# * Pitch
# * PointProcess
# * TextGrid
# * Intensity
# * Sound
# * Harmonicity

use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;
use File::Slurp;
use YAML::Tiny;
use Readonly;
use Pod::Usage;
use Encode qw(encode decode);

Readonly my $YAML   => 'yaml';
Readonly my $JSON   => 'json';
Readonly my $PRETTY => 'pretty';
Readonly my $MINI   => 'mini';

my $TAB_LENGTH = 4;
my $TAB        = " " x $TAB_LENGTH;
my $LEVEL      = 0;
my $INDENT     = set_indent();

my %setup;

$setup{'input'} = $JSON if $0 =~ /json/;

GetOptions (
  'yaml'       => sub { },
  'json'       => sub { $setup{'input'} = $JSON },
  'encoding=s' => \$setup{'encoding'},
  'help|?'     => sub { pod2usage( -verbose => 3 ) },
) or pod2usage(2);

$setup{'encoding'} = $setup{'encoding'} // 'UTF-8';

foreach (@ARGV) {
  if (-e $_) {
    my $input = read_file($_);
    eval {
      $input = decode($setup{encoding}, $input, Encode::FB_QUIET);
    };
    die("Error reading $_.\nAre you using the right encoding?") if $input eq "";
    
    my @KEYS = ('xmin', 'xmax');
    my $CLASS = undef;

    my $YAML = YAML::Tiny->read($_);

    foreach my $object (@{$YAML}) {
      print "File type = \"ooTextFile\"\n";
      $CLASS = $object->{'Object class'};
      print "Object class = \"$CLASS\"\n\n";
      delete $object->{'Object class'};
      
      print_object($object);
    }
  } else {
    die "Can't read file at $_: $!";
  }
}
  
sub print_object {
  my $object = shift;
  die "Not an object: $object" unless ref($object) eq 'HASH';
  
  my @keys = set_keys($object);
  foreach (@keys) {
    if (!ref($object->{$_})) {
      my $value = $object->{$_};
      if ($_ eq "tiers" and $value =~ /^<.*?>$/) {
        print $INDENT, $_, "? = ", $value, " \n";
      } else {
        $value =~ s/^([^-0-9.e]+)$/"$1"/;
        $value = '""' if $value eq "";
        
        print $INDENT, $_, " = ", $value, " \n";
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

sub print_list {
  my $name  = shift;
  my $list = shift;
  die "Not a list: $list" unless ref($list) eq 'ARRAY';
  
  if (ref($list->[0]) eq 'ARRAY') {
  
    print $INDENT, $_, ' [] []:', " \n";
    increase_indent();
    foreach my $i (1..@{$list}) {
      print $INDENT, $name, ' [', $i, "]:\n";
      increase_indent();
      foreach my $ii (1..@{$list->[$i-1]}) {
        print $INDENT, $name, ' [', $i, '] [', $ii, '] = ', $list->[$i-1]->[$ii-1], " \n";
      }
      decrease_indent();
    }
    decrease_indent();
    
  } else {
    if ($name =~ /^(intervals|points)$/) {
      print $INDENT, $name, ': size = ', $#{$list}, "\n";
    } else {
      print $INDENT, $_, ' []:', "\n";
    }
    increase_indent();
    foreach my $i (1..@{$list}) {
      if (ref($list->[$i-1])) {
        print $INDENT, $name, ' [', $i, "]:\n";
        increase_indent();
        print_object($list->[$i-1]);
        decrease_indent();
      } else {
        print $INDENT, $name, ' [', $i, '] = ', $list->[$i-1], " \n";
      }
    }

  }
  decrease_indent();
}

sub increase_indent {
  $LEVEL++;
  $INDENT = set_indent();
}

sub decrease_indent {
  $LEVEL--;
  $INDENT = set_indent();
}

sub set_indent {
  return $TAB x $LEVEL;
}

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
    push @keys, ('tiers', 'size', 'item');
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
    -encoding     Specify encoding of input file.
  
=head1 OPTIONS

=over 8

=item B<-yaml>

Read serial data from YAML.

=item B<-json>

Read serial data from YAML.

=item B<-encoding=CODE>

Specify the encoding of the input file. This script uses B<Encode> in the
background, so the file's I<CODE> can be any of the ones supported by that Perl
module. For a complete list, see

http://search.cpan.org/~jhi/perl-5.8.1/ext/Encode/lib/Encode/Supported.pod

If unspecified, the script defaults to reading as UTF-8. Output is always UTF-8.

=back

=head1 DESCRIPTION

This script takes a serialised representation of a Praat object in either JSON
or YAML and returns a version of the same data structure suitable to be read by
Praat. If the input format is not specified, YAML is assumed by default.

The script can be called as B<yaml2praat> or as B<json2praat>. The only
difference is that in the latter case, the I<-json> option is set by default.

=head1 SEE ALSO

praat2yaml(1), praat2json(1)

=cut
