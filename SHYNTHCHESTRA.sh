#!/bin/bash
#  ________   __    __    ___  ___   _____  ___   ___________   __    __   
# /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
#(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
# \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
#  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
# /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
#(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 
#


#######################################
# cleanup
trap cleanup SIGINT

cleanup() {
    echo -e "\nStopping all instruments. Goodbye!"
    # kill all kids
    pkill -P $$
    exit
}

#######################################
# help
usage() {
    cat README.txt
    exit 0
}

#######################################
# default values
ROOT="C"
SCALE="pentatonic"

#######################################
# parse flags
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
            *)
                echo "[ERROR] Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

#######################################
# MAIN
parse_args "$@"

clear
echo "▖ ▄▖▄▖   ▄▖▖▖▄▖   ▄▖▖▖▖▖▖ ▖▄▖▖▖▄▖▖▖▄▖▄▖▄▖▄▖▄▖   ▄▖▖ ▄▖▖▖"
echo "▌ ▙▖▐    ▐ ▙▌▙▖   ▚ ▙▌▌▌▛▖▌▐ ▙▌▌ ▙▌▙▖▚ ▐ ▙▘▌▌   ▙▌▌ ▌▌▌▌"
echo "▙▖▙▖▐    ▐ ▌▌▙▖   ▄▌▌▌▐ ▌▝▌▐ ▌▌▙▖▌▌▙▖▄▌▐ ▌▌▛▌   ▌ ▙▖▛▌▐ "
echo ""                                        

# bass
./SHYNTH.sh -t=noisy -r=$ROOT -s=$SCALE -p=tonics -o=3 -m=adagio -v=0.2 1>/dev/null &
sleep 0.05

# melody
./SHYNTH.sh -t=ep -r=$ROOT -s=$SCALE -p=random-melody -o=3 -m=allegro -v=1.5 1>/dev/null &
sleep 0.05

# arp
./SHYNTH.sh -t=sine -r=$ROOT -s=$SCALE -p=arp -o=4 -m=vivace -v=0.4 1>/dev/null &
sleep 0.05

# chord7
./SHYNTH.sh -t=mellow -r=$ROOT -s=$SCALE -p=chord7 -o=3 -m=adagio -v=1.1 1>/dev/null &
sleep 0.05

# ding
./SHYNTH.sh -t=saw -r=$ROOT -s=$SCALE -p=ding -o=4 -m=andante -v=0.1 1>/dev/null &
sleep 0.05

# duotones
./SHYNTH.sh -t=ep -r=$ROOT -s=$SCALE -p=duotones -o=4 -m=presto -v=0.7 1>/dev/null &

echo "    SHYNTHCHESTRA is playing! Press Ctrl+C to stop."
wait
