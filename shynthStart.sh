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
            *)
                echo "[ERROR] Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

#######################################
# MAIN
load_config
parse_args "$@"

echo "--- SHYNTH INITIALIZED ---"
echo "Root:    $ROOT"
echo "Scale:   $SCALE"
echo "Pattern: $PATTERN"
echo "Tone:    $TONE"
echo "--------------------------"

# TODO