#!/bin/bash

# ./show-database-info.sh data.txt data2.txt

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


LOG_FILE="../output/${i%}.info"
for i in "$@"; do
  log_time $LOG_FILE python ../run/show_dataset_info.py --file ${i%}  | tee /dev/tty | awk 'index($0, "\r") == 0'  
done
