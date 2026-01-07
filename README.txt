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
        ├─ /MIDItoSHYNTH.pm
        │
        └─ /shynthMIDI.pl



#### CONFIGURATION ####
-----------------------
You can edit shynthConfig.txt file to change shynth's properties:

root          [C, D, E, F, G, A, B (with sharps # or flats b)]
scale         [major, minor, dorian, phrygian, lydian, pentatonic]
pattern       [arp, chord, chord7, random-melody]
octave        [0-8]

tone          [ep, mellow, noisy, saw, sine]
midi          [filename](plays .mid file; overwrites root, scale, pattern, octave)

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

--midi: plays .mid file; overwrites -r, -s, -p, -o

-r: sets root of a scale, default C

-s: sets scale, default major

-p: sets pattern, default arp

-o: sets octave, default 3



Example: ./shynthStart.sh -r=G# -s=pentatonic -p=random-melody -t=mellow



========================================================================
=                        Developed by Jan Kwinta                       =
=                    07.01.2026 -- Version 1.02.115                    =
=               Latest version on: github.com/KwintaJ/SHYNTH           =
========================================================================
