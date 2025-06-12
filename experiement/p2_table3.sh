#!/bin/bash

# ./p2-table3.sh


# Manually set parameters
GRAM=2
PHRASE_THRESHOLD=100
echo "Running with GRAM=$GRAM, PHRASE_THRESHOLD=$PHRASE_THRESHOLD"
read -p "Press [Enter] to continue or Ctrl+C to exit..."
# waiting until user confirms y


# 로그 함수 정의
log_time() {
        echo "Running: $*" | tee -a "$1"
        start=$(date +%s)
        "$@" 2>&1 | tee -a "$1"
        end=$(date +%s)
        echo "Time elapsed: $((end - start))s" | tee -a "$logfile"
        echo "" | tee -a "$1"
}
#!/bin/bash

# 공통 설정

# DATASET="../data/data_phrase_gram=${GRAM}_th=${PHRASE_THRESHOLD}.txt"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
BASE_OUTPUT_DIR="../output/p2_table3_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

# 데이터셋 분할
# bash ../scripts/split-dataset.sh "$DATASET" 1B


# 조합 리스트 (형식: "iter dim size model")
combinations=(
  "3 300 1B skip-gram 5 0"
  "3 300 1B skip-gram 15 0"
  "3 300 1B skip-gram 0 0"
  "3 300 1B skip-gram 5 1e-5"
  "3 300 1B skip-gram 15 1e-5"
  "3 300 1B skip-gram 0 1e-5"
)

# 반복 실행
for combo in "${combinations[@]}"; do
  read ITER DIM SIZE MODEL NS SUBSAMPLE <<< "$combo"
  
  INPUT_FILE="../data/data_phrase_gram=${GRAM}_th=${PHRASE_THRESHOLD}.txt"
  if [ ! -f "$INPUT_FILE" ]; then
    echo "[SKIP] $INPUT_FILE not found."
    continue
  fi

  OUTPUT_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}_ns${NS}_s${SUBSAMPLE}.bin"
  LOG_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}_ns${NS}_s${SUBSAMPLE}.log"
  
  echo "▶ Training Word2Vec ($MODEL) on $INPUT_FILE with dim=$DIM, iter=$ITER..." | tee -a "$LOG_FILE"
  
  if [ "$MODEL" == "cbow" ]; then
    CBOW_FLAG=1
  elif [ "$MODEL" == "skip-gram" ]; then
    CBOW_FLAG=0
  end

  # if $ns is greater than 0, HS_FLAG = 0 or 1
  if [ "$NS" -gt 0 ]; then
    HS_FLAG=0
  else
    HS_FLAG=1
  fi

  log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
    -cbow "$CBOW_FLAG" -size "$DIM" -window 5 -negative "$NS" -hs "$HS_FLAG" -sample "$SUBSAMPLE" \
    -threads 20 -binary 1 -iter "$ITER" -min-count 5

  echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/questions-words.txt | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/msr.txt | tee -a "$LOG_FILE"

  echo "✔ Done: $OUTPUT_FILE"
  echo ""
done
