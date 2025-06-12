#!/bin/bash

# ./p1-table3.sh

# 로그 함수 정의
log_time() {
        echo "Running: $*" | tee -a "$1"
        start=$(date +%s)
        "$@" 2>&1 | tee -a "$1"
        end=$(date +%s)
        echo "Time elapsed: $((end - start))s" | tee -a "$logfile"
        echo "" | tee -a "$1"
}

# 사전 정의된 파라미터
DIMENSIONS=(640)
TRAINING_SIZES=(320M)
DATASET="../data/14b.txt"

TIMESTAMP=$(date +"%Y%m%d_%H%M")

BASE_OUTPUT_DIR="../output/p1_table3_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

bash ../scripts/split-dataset.sh "$DATASET" "${TRAINING_SIZES[@]}"
# 각 조합에 대해 반복
for DIM in "${DIMENSIONS[@]}"; do
  for SIZE in "${TRAINING_SIZES[@]}"; do
    INPUT_FILE="../data/14b_${SIZE}.txt"
    
    # for CBOW
    OUTPUT_FILE="${BASE_OUTPUT_DIR}/cbow_${SIZE}_${DIM}d.bin"
    LOG_FILE="${BASE_OUTPUT_DIR}/cbow_${SIZE}_${DIM}d.log"
    
    if [ ! -f "$INPUT_FILE" ]; then
      echo "[SKIP] $INPUT_FILE not found." | tee -a "$LOG_FILE"
      continue
    fi

    echo "▶ Training Word2Vec on $INPUT_FILE with dimension $DIM..." | tee -a "$LOG_FILE"
    log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
      -cbow 1 -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
      -threads 20 -binary 1 -iter 3 -min-count 10

    echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
    log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/questions-words.txt | tee "acc_${SIZE}_${DIM}d.txt"
    log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/msr.txt | tee "acc_${SIZE}_${DIM}d.txt"


    # for Skip-gram
    OUTPUT_FILE="${BASE_OUTPUT_DIR}/skip-gram_${SIZE}_${DIM}d.bin"
    LOG_FILE="${BASE_OUTPUT_DIR}/skip-gram_${SIZE}_${DIM}d.log"
    
    if [ ! -f "$INPUT_FILE" ]; then
      echo "[SKIP] $INPUT_FILE not found." | tee -a "$LOG_FILE"
      continue
    fi

    echo "▶ Training Word2Vec on $INPUT_FILE with dimension $DIM..." | tee -a "$LOG_FILE"
    log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
      -cbow 0 -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
      -threads 20 -binary 1 -iter 3 -min-count 10

    echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
    log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/questions-words.txt | tee "acc_${SIZE}_${DIM}d.txt"
    log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/msr.txt | tee "acc_${SIZE}_${DIM}d.txt"

    echo "✔ Done: $OUTPUT_FILE"
    echo ""
  done
done