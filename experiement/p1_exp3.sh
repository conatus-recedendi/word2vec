#!/bin/bash

# ./p1_exp3 ../output/p1_table3

# p1_table5 에서 "Acccuracy is reported on the full semantic-syntatic data set"이라고 해서 threshold 완전 제거
#!/bin/bash

# ./p1-exp2.sh ../output/p1_table2_20250612_0655

# p1_table5에서 구한 binary 데이터를 가지고, auccraecy threshold 400K개만 측정한 실험

# 로그 함수 정의
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



# 사전 정의된 파라미터
DIMENSIONS=(640)
TRAINING_SIZES=(320M)
DATASET="../data/14b.txt"

TIMESTAMP=$(date +"%Y%m%d_%H%M")

BASE_OUTPUT_DIR="../output/p1_exp2_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

REF_OUTPUT_DIR=$1

# bash ../scripts/split-dataset.sh "$DATASET" "${TRAINING_SIZES[@]}"
# 각 조합에 대해 반복
for DIM in "${DIMENSIONS[@]}"; do
  for SIZE in "${TRAINING_SIZES[@]}"; do
    INPUT_FILE="../data/14b_${SIZE}.txt"
    
    OUTPUT_FILE="${REF_OUTPUT_DIR}/${SIZE}_${DIM}d.bin"
    LOG_FILE="${BASE_OUTPUT_DIR}/${SIZE}_${DIM}d.log"
    
    if [ ! -f "$INPUT_FILE" ]; then
      echo "[SKIP] $INPUT_FILE not found." | tee -a "$LOG_FILE"
      continue
    fi

    if [ ! -f "$OUTPUT_FILE" ]; then
      echo "[SKIP] $OUTPUT_FILE not found." | tee -a "$LOG_FILE"
      continue
    fi

    # echo "▶ Training Word2Vec on $INPUT_FILE with dimension $DIM..." | tee -a "$LOG_FILE"
    # log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
    #   -cbow 1 -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
    #   -threads 20 -binary 1 -iter 3 -min-count 10

    echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
    log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" < ../data/questions-words.txt

    echo "✔ Done: $OUTPUT_FILE"
    echo ""
  done
done