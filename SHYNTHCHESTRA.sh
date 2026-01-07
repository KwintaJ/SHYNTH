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
SCALE="major"

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
./shynthStart.sh -t=noisy -r=$ROOT -s=$SCALE -p=tonics -o=3 -m=adagio -v=0.2 1>/dev/null &

# melody
./shynthStart.sh -t=ep -r=$ROOT -s=$SCALE -p=random-melody -o=3 -m=allegro -v=1.5 1>/dev/null &

# arp
./shynthStart.sh -t=sine -r=$ROOT -s=$SCALE -p=arp -o=4 -m=vivace -v=0.4 1>/dev/null &

# chord7
./shynthStart.sh -t=mellow -r=$ROOT -s=$SCALE -p=chord7 -o=3 -m=adagio -v=1.1 1>/dev/null &

# ding
./shynthStart.sh -t=saw -r=$ROOT -s=$SCALE -p=ding -o=4 -m=andante -v=0.1 1>/dev/null &

# duotones
./shynthStart.sh -t=ep -r=$ROOT -s=$SCALE -p=duotones -o=4 -m=presto -v=0.7 1>/dev/null &

echo "    SHYNTHCHESTRA is playing! Press Ctrl+C to stop."
wait
