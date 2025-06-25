#!/bin/bash

# bash ./p1_exp2_show_vocab.sh ../data/14b_783M.txt ../data/14b_24M.txt --file_base "../data/questions-words.txt"

log_time() {
        logfile="$1"
        shift
        echo "Running: $*" | tee -a "$logfile"
        start=$(date +%s)
        "$@" 2>&1 | tee /dev/tty | awk 'index($0, "\r") == 0' >> "$logfile"
        end=$(date +%s)
        echo "Time elapsed: $((end - start))s" | tee -a "$logfile"
        echo "" | tee -a "$logfile"
}

LOG_FILE="../output/p1_exp2_show_vocab_$(date +"%Y%m%d_%H%M").log"


log_time $LOG_FILE python ../run/p1_exp2_show_vocab.py --file1 "$1" --file2 "$2" --file_base "$3" --topk 30000