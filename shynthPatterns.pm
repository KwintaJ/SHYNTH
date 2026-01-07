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
    my ($root, $scale, $octave, $tempo) = @_;
    my @notes = get_scale_notes($root, $scale, $octave);
    my @sequence = (@notes, reverse @notes[1..$#notes-1]);
    my $duration = 0.12 * $tempo;
    return map { "$_ $duration" } @sequence;
}

sub play_chord {
    my ($root, $scale, $octave, $tempo) = @_;
    my @scale_notes = get_scale_notes($root, $scale, $octave);
    my @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[4]);
    my $duration = 10.0 * $tempo;
    return "(" . join(" ", @chord_notes) . ") " . $duration;
}

sub play_chord7 {
    my ($root, $scale, $octave, $tempo) = @_;
    my @scale_notes = get_scale_notes($root, $scale, $octave);
    my @chord_notes;
    if ($scale ne "pentatonic") {
        @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[4], $scale_notes[6]);
    }
    else {
        @chord_notes = ($scale_notes[0], $scale_notes[2], $scale_notes[3], $scale_notes[4]);
    }
    my $duration = 10.0 * $tempo;
    return "(" . join(" ", @chord_notes) . ") " . $duration;
}

sub play_random_melody {
    my ($root, $scale, $octave, $tempo) = @_;
    my @notes_low  = get_scale_notes($root, $scale, $octave);
    my @notes_high = get_scale_notes($root, $scale, $octave + 1);
    my @all_notes  = (@notes_low, @notes_high);
    
    my @output;
    my @durations = (0.25 * $tempo, 0.33 * $tempo, 0.5 * $tempo);

    for (my $i = 0; $i < 50; $i++) {
        
        # rest
        my $note_to_play;
        if (rand() < 0.25) {
            $note_to_play = -1;
        } else {
            if (rand() < 0.20) {
                $note_to_play = $all_notes[0];
            } else {
                $note_to_play = $all_notes[int(rand(@all_notes))];
            }
        }
        
        my $d_idx = int(rand(@durations));    
        my $line = sprintf("%d %.2f", $note_to_play, $durations[$d_idx]);
        push @output, $line;
    }
    
    return @output;
}

sub play_tonics {
    my ($root, $scale, $octave, $tempo) = @_;
    my @note1 = get_scale_notes($root, $scale, $octave - 1);
    my @note2 = get_scale_notes($root, $scale, $octave);
    my @tonics  = ($note1[0], $note2[0]);
    my $duration = 0.4 * $tempo;
    return map { "$_ $duration" } @tonics;
}

1;
