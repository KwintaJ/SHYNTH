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
use shynthPatterns;

#######################################
# vars
my $root;
my $scale;
my $pattern;
my $octave;
my $metronome;

#######################################
# args from shynthStart
GetOptions(
    "root=s"       => \$root,
    "scale=s"      => \$scale,
    "pattern=s"    => \$pattern,
    "octave=i"     => \$octave,
    "metronome=s"  => \$metronome,
);

#######################################
# tempo select
my $metronome_val;

if ($metronome eq "adagio") {
    $metronome_val = 2
}
elsif ($metronome eq "andante") {
    $metronome_val = 1.45
}
elsif ($metronome eq "moderato") {
    $metronome_val = 1
}
elsif ($metronome eq "allegro") {
    $metronome_val = 0.9
}
elsif ($metronome eq "vivace") {
    $metronome_val = 0.7
}
elsif ($metronome eq "presto") {
    $metronome_val = 0.55
}

#######################################
# generate notes
my @sequence;

if ($pattern eq "arp") {
    @sequence = shynthPatterns::play_arp($root, $scale, $octave, $metronome_val);
} 
elsif ($pattern eq "chord") {
    @sequence = shynthPatterns::play_chord($root, $scale, $octave, $metronome_val);
} 
elsif ($pattern eq "chord7") {
    @sequence = shynthPatterns::play_chord7($root, $scale, $octave, $metronome_val);
} 
elsif ($pattern eq "random-melody") {
    @sequence = shynthPatterns::play_random_melody($root, $scale, $octave, $metronome_val);
}
elsif ($pattern eq "tonics") {
    @sequence = shynthPatterns::play_tonics($root, $scale, $octave, $metronome_val);
} 

foreach my $line (@sequence) {
    print "$line\n";
}
