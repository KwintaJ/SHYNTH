package shynthPatterns;

use strict;
use warnings;

#######################################
# notes to midi
my %note_map = (
    'C'  => 0,
    'C#' => 1,
    'Db' => 1,
    'D'  => 2,
    'D#' => 3,
    'Eb' => 3,
    'E'  => 4,
    'E#'  => 5,
    'Fb'  => 4,
    'F'  => 5,
    'F#' => 6,
    'Gb' => 6,
    'G'  => 7,
    'G#' => 8,
    'Ab' => 8,
    'A'  => 9,
    'A#' => 10,
    'Bb' => 10,
    'B'  => 11,
    'B#'  => 0,
    'Cb'  => 11
);

#######################################
# scales definitions
my %scales = (
    'major'      => [0, 2, 4, 5, 7, 9, 11],
    'minor'      => [0, 2, 3, 5, 7, 8, 10],
    'dorian'     => [0, 2, 3, 5, 7, 9, 10],
    'phrygian'   => [0, 1, 3, 5, 7, 8, 10],
    'lydian'     => [0, 2, 4, 6, 7, 9, 11],
    'pentatonic' => [0, 2, 4, 7, 9],
);

#######################################
# scale generation
sub get_scale_notes {
    my ($root_name, $scale_name, $octave) = @_;
    my $root_offset = $note_map{$root_name} + (($octave + 1) * 12);
    my @intervals = @{$scales{$scale_name}};
    
    return map { $root_offset + $_ } @intervals;
}

#######################################
# patterns
sub play_arp {
    my ($root, $scale, $octave) = @_;
    my @notes = get_scale_notes($root, $scale, $octave);
    my @sequence = (@notes, reverse @notes[1..$#notes-1]);
    return map { "$_ 0.2" } @sequence;
}

sub play_chord {
    my ($root, $scale, $octave) = @_;
    my @scale_notes = get_scale_notes($root, $scale, $octave);
    my @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[4]);
    return "(" . join(" ", @chord_notes) . ") 10.0";
}

sub play_chord7 {
    my ($root, $scale, $octave) = @_;
    my @scale_notes = get_scale_notes($root, $scale, $octave);
    my @chord_notes;
    if ($scale ne "pentatonic") {
        @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[4], $scale_notes[6]);
    }
    else {
        @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[3], $scale_notes[4]);
    }
    return "(" . join(" ", @chord_notes) . ") 10.0";
}

sub play_random_melody {
    my ($root, $scale, $octave) = @_;
    my @notes = get_scale_notes($root, $scale, $octave);
    my @output;
    my $pos = int(rand(@notes));
    
    for (1..16) {
        $pos = ($pos + (int(rand(3)) - 1)) % scalar(@notes);
        push @output, "$notes[$pos] 0.25";
    }
    return @output;
}

1;
