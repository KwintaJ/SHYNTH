#  ________   __    __    ___  ___   _____  ___   ___________   __    __   
# /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
#(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
# \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
#  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
# /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
#(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 
#
#!/bin/bash

#######################################
# cleanup
trap cleanup SIGINT SIGTERM EXIT

cleanup() {
    trap - SIGINT SIGTERM EXIT

    if [[ -f "$TEMP_NOTE_DATA" ]]; then
        rm -f "$TEMP_NOTE_DATA"
    fi
    
    local pids=$(jobs -p)
    if [[ -n "$pids" ]]; then
        kill $pids 2>/dev/null
    fi

    echo ""
    echo "SHYNTH was shut down. Goodbye!"
    exit 0
}

#######################################
# help
usage() {
    cat README.txt
    exit 0
}

#######################################
# default values
CONFIG_FILE="shynthConfig.txt"
ROOT="C"
SCALE="pentatonic"
PATTERN="arp"
TONE="ep"
OCTAVE=3
METRONOME="moderato"
VOLUME=1
TEMP_NOTE_DATA="./.shynthNotesData_$$.tmp"
AUDIO_PLAYER=""

#######################################
# check permissions, files
check_environment() {
    # check write permissions
    if [[ ! -w "." ]]; then
        echo "[ERROR] No write permission in the current directory ($(pwd))."
        echo "        SHYNTH cannot create temporary files."
        exit 1
    fi

    # check for shynth components
    local scripts=("shynthNotes.pl" "shynthVoice.py")
    for s in "${scripts[@]}"; do
        if [[ ! -f "$s" ]]; then
            echo "[ERROR] Missing component: $s"
            exit 1
        fi
        if [[ ! -x "$s" ]]; then
            echo "[ERROR] Cannot use $s. Check permissions."
            exit 1
        fi
    done
}

#######################################
# check which audio player to use
check_audio_tools() {    
    if command -v aplay >/dev/null 2>&1; then
        AUDIO_PLAYER="aplay -r 44100 -f S16_LE -c 1"
        echo "SHYNTH will be using aplay audio player."
    elif command -v ffplay >/dev/null 2>&1; then
        AUDIO_PLAYER="ffplay -nodisp -autoexit -f s16le -ar 44100 -ac 1 -i pipe:0"
        echo "SHYNTH will be using ffplay audio player."
    elif command -v sox >/dev/null 2>&1; then
        AUDIO_PLAYER="play -t raw -r 44100 -e signed-integer -b 16 -c 1 -"
        echo "SHYNTH will be using sox audio player."
    else
        echo "[ERROR] No supported audio player found (aplay, ffplay, or sox)."
        echo "        Try to install any of those audio controllers:"
        echo "          On Ubuntu/Debian: sudo apt-get install alsa-utils"
        echo "          On macOS: brew install sox"
        exit 1
    fi
}

#######################################
# load config.txt
# parse line by line, ignore comments, ignore empty lines
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS=' ' read -r key value; do
            [[ -z "$key" || "$key" == "#"* ]] && continue
            
            case "$key" in
                root)      ROOT="$value" ;;
                scale)     SCALE="$value" ;;
                pattern)   PATTERN="$value" ;;
                tone)      TONE="$value" ;;
                octave)    OCTAVE="$value" ;;
                metronome) METRONOME="$value" ;;
                volume)    VOLUME="$value" ;;
            esac
        done < "$CONFIG_FILE"
    fi
}

#######################################
# parse flags, priority over config.txt
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -r=*)
                ROOT="${1#*=}"
                shift
                ;;
            -s=*)
                SCALE="${1#*=}"
                shift
                ;;
            -p=*)
                PATTERN="${1#*=}"
                shift
                ;;
            -t=*)
                TONE="${1#*=}"
                shift
                ;;
            -o=*)
                OCTAVE="${1#*=}"
                shift
                ;;
            -m=*)
                METRONOME="${1#*=}"
                shift
                ;;
            -v=*)
                VOLUME="${1#*=}"
                shift
                ;;
            *)
                echo "[ERROR] Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

#######################################
# legal values and check
LEGAL_ROOTS=("C" "C#" "Db" "D" "D#" "Eb" "E" "E#" "Fb" "F" "F#" "Gb" "G" "G#" "Ab" "A" "A#" "Bb" "B" "B#" "Cb")
LEGAL_SCALES=("major" "minor" "dorian" "phrygian" "lydian" "pentatonic")
LEGAL_PATTERNS=("arp" "chord" "chord7" "random-melody" "tonics" "ding" "duotones")
LEGAL_TONES=("ep" "mellow" "noisy" "saw" "sine")
LEGAL_METRONOMES=("adagio" "andante" "moderato" "allegro" "vivace" "presto")

is_legal() {
    local element=$1
    shift
    local array=("$@")
    for i in "${array[@]}"; do
        if [[ "$i" == "$element" ]]; then
            return 0
        fi
    done
    return 1
}

validate_settings() {
    local errors=0

    if ! is_legal "$ROOT" "${LEGAL_ROOTS[@]}"; then
        echo "[ERROR] Invalid root note: $ROOT. Use one of: ${LEGAL_ROOTS[*]}"
        ((errors++))
    fi

    if ! is_legal "$SCALE" "${LEGAL_SCALES[@]}"; then
        echo "[ERROR] Invalid scale: $SCALE. Use one of: ${LEGAL_SCALES[*]}"
        ((errors++))
    fi

    if ! is_legal "$PATTERN" "${LEGAL_PATTERNS[@]}"; then
        echo "[ERROR] Invalid pattern: $PATTERN. Use one of: ${LEGAL_PATTERNS[*]}"
        ((errors++))
    fi

    if ! is_legal "$TONE" "${LEGAL_TONES[@]}"; then
        echo "[ERROR] Invalid tone: $TONE. Use one of: ${LEGAL_TONES[*]}"
        ((errors++))
    fi

    if ! [[ "$OCTAVE" =~ ^[0-8]$ ]]; then
        echo "[ERROR] Invalid octave: $OCTAVE. Use range 0-8."
        ((errors++))
    fi

    if ! is_legal "$METRONOME" "${LEGAL_METRONOMES[@]}"; then
        echo "[ERROR] Invalid metronome tempo: $METRONOME. Use one of: ${LEGAL_METRONOMES[*]}"
        ((errors++))
    fi

    if ! [[ $VOLUME =~ ^(0\.[1-9][0-9]*|1\.[0-9][0-9]*|1)$ ]]; then
        echo "[ERROR] Invalid volume: $VOLUME. Use range 0.1 - 1.9"
        ((errors++))
    fi

    if [[ $errors > 0 ]]; then
        exit 1
    fi
}

#######################################
# get perl to generate notes
run_create_midi() {    
    if ! perl ./shynthNotes.pl --root="$ROOT" --scale="$SCALE" --pattern="$PATTERN" --octave="$OCTAVE" --metronome="$METRONOME" > "$TEMP_NOTE_DATA"; then
        echo "[ERROR] Perl script failed to generate notes"
        exit 2
    fi

    # check if note file empty
    if [[ ! -s "$TEMP_NOTE_DATA" ]]; then
        echo "[ERROR] Note data file is empty - Perl error"
        exit 3
    fi
}

    
#######################################
# get python to play sounds   
run_python_synth() {
    echo "Starting Loop Engine. Press Ctrl+C to stop."
    ( python3 ./shynthVoice.py --input="$TEMP_NOTE_DATA" --tone="$TONE" --volume="$VOLUME" | $AUDIO_PLAYER 2>/dev/null) &
    MAIN_PID=$!

    wait $MAIN_PID 2>/dev/null
}

#######################################
# MAIN
check_environment
load_config
parse_args "$@"
validate_settings
check_audio_tools

clear
echo "--------------------------------------------"
echo "             SHYNTH INITIALIZED             "
echo ""
echo "Root:                 $ROOT"
echo "Scale:                $SCALE"
echo "Pattern:              $PATTERN"
echo "Tone:                 $TONE"
echo "Octave:               $OCTAVE"
echo "Metronome tempo:      $METRONOME"
echo "Volume:               $VOLUME"
echo "--------------------------------------------"

run_create_midi
run_python_synth
