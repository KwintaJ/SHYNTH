#  ________   __    __    ___  ___   _____  ___   ___________   __    __   
# /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
#(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
# \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
#  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
# /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
#(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 
#
#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

#######################################
# config
my $root = "C";
my $scale = "major";
my $pattern = "arp";
my $bpm = 120;

#######################################
# args from shynthStart
GetOptions(
    "root=s" => \$root,
    "scale=s" => \$scale,
    "pattern=s" => \$pattern,
);

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
    
    my @midi_notes = map { $root_offset + $_ } @intervals;
    return @midi_notes;
}

#######################################
# patterns
sub gen_pattern {
    my @notes = get_scale_notes($root, $scale, 3);

    foreach my $n (@notes) {
        printf("%d %.2f\n", $n, 0.5);
    }

    # TODO
}

#######################################
# MAIN
gen_pattern();