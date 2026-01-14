  ________   __    __    ___  ___   _____  ___   ___________   __    __   
 /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
 \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
 /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 

========================================================================
=                                                                      =
=                    This is SHYNTH - ShellSynth                       =
=       Music tool for generating procedural, pseudo-random            =
=                tones, arps, drone notes and melodies                 =
=                                                                      =
========================================================================



########################################################################
#### INSTALLATION ####
----------------------
Be sure to have all those files in one directory:
    
    /SHYNTH
        │
        ├─ /README.txt (this file)
        │
        ├─ /SHYNTH.sh
        │
        ├─ /SHYNTHCHESTRA.sh
        │
        ├─ /shynthNotes.pl
        │
        ├─ /shynthPatterns.pm
        │
        ├─ /shynthVoice.py
        │
        └─ /shynthConfig.txt



########################################################################
#### USAGE ####
---------------
To use SHYNTHCHESTRA (SHYNTH Orchestra) and unleash pandemonium:
    - Run /SHYNTH/SHYNTHCESTRA.sh [FLAGS] from terminal

Example: ./SHYNTHCESTRA.sh -r=Eb -s=pentatonic


---------------
To use SHYNTH as a solo voice:
    - Run /SHYNTH/SHYNTH.sh [FLAGS] from terminal

Example: ./SHYNTH.sh -t=mellow -r=G# -s=lydian -p=chord7 -o=3



########################################################################
#### FLAGS ####
---------------
Flags for SHYNTHCESTRA.sh:
    -r: sets root of a scale
    -s: sets scale


---------------
Flags for SHYNTH.sh:
    -h --help: prints this file
    -t: sets tone
    -r: sets root of a scale
    -s: sets scale
    -p: sets pattern
    -o: sets octave
    -m: sets metronome tempo
    -v: sets volume



########################################################################
#### CONFIGURATION ####
-----------------------
To change SHYNTH's properties you can use flags or
edit shynthConfig.txt file


tone          [ep (electric piano), mellow, noisy, saw, sine]
               default ep

root          [C, D, E, F, G, A, B] (with sharps # or flats b) 
               default C

scale         [major, minor, dorian, phrygian, lydian, pentatonic]
               default pentatonic

pattern       [arp, chord, chord7, random-melody, tonics,
               ding, duotones]
               default arp

octave        [0 - 8]
               default 3

metronome     [adagio, andante, moderato, allegro, vivace, presto]
              (slowest to fastest) default moderato

volume        [0.1 - 1.9]
               default 1.0




========================================================================
=                        Developed by Jan Kwinta                       =
=                    14.01.2026 -- Version 3.04.200                    =
=               Latest version on: github.com/KwintaJ/SHYNTH           =
========================================================================
