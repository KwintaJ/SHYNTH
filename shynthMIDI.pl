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

use lib '.'; 
use MIDItoSHYNTH;
use shynthPatterns;

#######################################
# vars
my $root;
my $scale;
my $pattern;
my $octave;
my $midi_file_input;

#######################################
# args from shynthStart
GetOptions(
    "root=s"            => \$root,
    "scale=s"           => \$scale,
    "pattern=s"         => \$pattern,
    "octave=i"          => \$octave,
    "midi=s"            => \$midi_file_input
);

#######################################
# generate notes
my @sequence;

if ($midi_file_input ne "_") {
    if (-e $midi_file_input && -f $midi_file_input) {
        if (-s $midi_file_input > 0) {
            print STDERR "[INFO] Importing MIDI file: $midi_file_input\n";
            @sequence = MIDItoSHYNTH::convert_midi_to_shynth($midi_file_input);
        } else {
            die "[ERROR] MIDI file '$midi_file_input' is empty.\n";
        }
    } else {
        die "[ERROR] MIDI file '$midi_file_input' not found.\n";
    }
}
elsif ($pattern eq "arp") {
    @sequence = shynthPatterns::play_arp($root, $scale, $octave);
} 
elsif ($pattern eq "chord") {
    @sequence = shynthPatterns::play_chord($root, $scale, $octave);
} 
elsif ($pattern eq "chord7") {
    @sequence = shynthPatterns::play_chord7($root, $scale, $octave);
} 
elsif ($pattern eq "random-melody") {
    @sequence = shynthPatterns::play_random_melody($root, $scale, $octave);
} 

foreach my $line (@sequence) {
    print "$line\n";
}
