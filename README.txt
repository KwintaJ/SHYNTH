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


#### INSTALLATION ####
----------------------
Be sure to have all those files in one directory:
    
    /SHYNTH
        │
        ├─ /README.txt (this file)
        │
        ├─ /shynthStart.sh
        │
        ├─ /shynthConfig.txt
        │
        ├─ /shynthVoice.py
        │
        ├─ /shynthPatterns.pm
        │
        └─ /shynthMIDI.pl



#### CONFIGURATION ####
-----------------------
You can edit shynthConfig.txt file to change shynth's properties:

tone          [ep (electric piano), mellow, noisy, saw, sine]

root          [C, D, E, F, G, A, B]
              (with sharps # or flats b)

scale         [major, minor, dorian, phrygian, lydian, pentatonic]

pattern       [arp, chord, chord7, random-melody]

octave        [0-8]

metronome     [adagio, andante, moderato, allegro, vivace, presto]
              (slowest to fastest)

#### USAGE ####
---------------
Either:
    - With shynthConfig.txt present and set up run shynthStart.sh file
Or:
    - Run /SHYNTH/shynthStart.sh [FLAGS] from terminal



#### FLAGS ####
---------------

-h --help: prints this file

-t: sets tone, default ep (electric piano)

-r: sets root of a scale, default C

-s: sets scale, default major

-p: sets pattern, default arp

-o: sets octave, default 3

-m: sets metronome tempo, default moderato



Example: ./shynthStart.sh -t=mellow -r=G# -s=lydian -p=chord7 -o=3



========================================================================
=                        Developed by Jan Kwinta                       =
=                    07.01.2026 -- Version 2.01.000                    =
=               Latest version on: github.com/KwintaJ/SHYNTH           =
========================================================================
