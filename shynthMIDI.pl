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

#######################################
# args from shynthStart
GetOptions(
    "root=s"    => \$root,
    "scale=s"   => \$scale,
    "pattern=s" => \$pattern,
    "octave=i"  => \$octave,
);

#######################################
# generate MIDI
my @sequence;

if ($pattern eq "arp") {
    @sequence = shynthPatterns::play_arp($root, $scale, $octave);
} 
elsif ($pattern eq "drone") {
    @sequence = shynthPatterns::play_drone($root, $scale, $octave);
} 
elsif ($pattern eq "chord") {
    @sequence = shynthPatterns::play_chord($root, $scale, $octave);
} 
elsif ($pattern eq "random-melody") {
    @sequence = shynthPatterns::play_random_melody($root, $scale, $octave);
} 

foreach my $line (@sequence) {
    print "$line\n";
}
