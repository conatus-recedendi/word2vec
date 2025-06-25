

# ./reduce_dataset_by_vocab.sh <input_file> <output_file> <threshold>
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


LOG_FILE="../output/reduce_dataset_by_vocab_$(date +"%Y%m%d_%H%M").log"

log_time $LOG_FILE python ../run/reduce_dataset_by_vocab.py --file "$1" --output "$2" --threshold "$3"