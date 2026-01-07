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
# default values
CONFIG_FILE="shynthConfig.txt"
ROOT="C"
SCALE="major"
PATTERN="arp"
TONE="ep"
OCTAVE=3
TEMP_NOTE_DATA="./.shynthNotes.tmp"
AUDIO_PLAYER=""

#######################################
# legal values
LEGAL_ROOTS=("C" "C#" "Db" "D" "D#" "Eb" "E" "E#" "Fb" "F" "F#" "Gb" "G" "G#" "Ab" "A" "A#" "Bb" "B" "B#" "Cb")
LEGAL_SCALES=("major" "minor" "dorian" "phrygian" "lydian" "pentatonic")
LEGAL_PATTERNS=("arp" "drone" "chord" "random-melody")
LEGAL_TONES=("ep" "sharp" "mellow" "noisy" "saw" "sine")

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
    local scripts=("shynthMIDI.pl" "shynthVoice.py")
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

    # check touch file
    local test_file="./.shynth_test"
    if ! touch "$test_file" 2>/dev/null; then
        echo "[ERROR] Failed to create a file. Disk full or permission needed."
        exit 1
    else
        rm "$test_file"
    fi
}

#######################################
# check which audio player to use
check_audio_tools() {    
    if command -v aplay >/dev/null 2>&1; then
        AUDIO_PLAYER="aplay -r 44100 -f S16_LE -c 1"
        echo "[INFO] Using aplay audio player"
    elif command -v ffplay >/dev/null 2>&1; then
        AUDIO_PLAYER="ffplay -nodisp -autoexit -f s16le -ar 44100 -ac 1 -i pipe:0"
        echo "[INFO] Using ffplay audio player"
    elif command -v sox >/dev/null 2>&1; then
        AUDIO_PLAYER="play -t raw -r 44100 -e signed-integer -b 16 -c 1 -"
        echo "[INFO] Using sox audio player"
    else
        echo "[ERROR] No supported audio player found (aplay, ffplay, or sox)."
        echo "        Try to nstall any of those audio controllers:"
        echo "          On Ubuntu/Debian: sudo apt-get install alsa-utils"
        echo "          On macOS: brew install sox"
        exit 1
    fi
}

#######################################
# help
usage() {
    cat README.txt
    exit 0
}

#######################################
# load config.txt
# parse line by line, ignore comments, ignore empty lines
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS=' ' read -r key value; do
            [[ -z "$key" || "$key" == "#"* ]] && continue
            
            case "$key" in
                root)    ROOT="$value" ;;
                scale)   SCALE="$value" ;;
                pattern) PATTERN="$value" ;;
                tone)    TONE="$value" ;;
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
            *)
                echo "[ERROR] Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

#######################################
# two functions for config validation
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
        exit 1
    fi

    if [[ $errors > 0 ]]; then
        exit 1
    fi
}

#######################################
# get perl to generate notes
run_create_midi() {
    echo "[INFO] Generating melodic data"
    
    if ! perl ./shynthMIDI.pl --root="$ROOT" --scale="$SCALE" --pattern="$PATTERN" --octave="$OCTAVE" > "$TEMP_NOTE_DATA"; then
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
    echo "[INFO] Starting Loop Engine. Press Ctrl+C to stop."
    python3 ./shynthVoice.py --input="$TEMP_NOTE_DATA" --tone="$TONE" | $AUDIO_PLAYER
}

#######################################
# MAIN
check_environment
load_config
parse_args "$@"
validate_settings

echo "--- SHYNTH INITIALIZED ---"
echo "Root:    $ROOT"
echo "Scale:   $SCALE"
echo "Pattern: $PATTERN"
echo "Tone:    $TONE"
echo "--------------------------"

check_audio_tools
run_create_midi
run_python_synth
