#!/bin/bash

# ./p1-table6.sh

# 로그 함수 정의
log_time() {
        logfile="$1"
        shift
        echo "Running: $*" | tee -a "$logfile"
        start=$(date +%s)
        "$@" 2>&1 | awk '{ if ($0 !~ /\r/) print }' | tee -a "$logfile"
        end=$(date +%s)
        echo "Time elapsed: $((end - start))s" | tee -a "$logfile"
        echo "" | tee -a "$logfile"
}


#!/bin/bash

# 공통 설정
DATASET="../data/14b.txt"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
BASE_OUTPUT_DIR="../output/p1_table6_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

# 데이터셋 분할
bash ../scripts/split-dataset.sh "$DATASET" 6B

# 조합 리스트 (형식: "iter dim size model")
combinations=(
  "3 1000 6B cbow"
  "3 1000 6B skip-gram"
)

# 반복 실행
for combo in "${combinations[@]}"; do
  read ITER DIM SIZE MODEL <<< "$combo"
  
  INPUT_FILE="../data/14b_${SIZE}.txt"
  if [ ! -f "$INPUT_FILE" ]; then
    echo "[SKIP] $INPUT_FILE not found."
    continue
  fi

  OUTPUT_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.bin"
  LOG_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.log"
  
  echo "▶ Training Word2Vec ($MODEL) on $INPUT_FILE with dim=$DIM, iter=$ITER..." | tee -a "$LOG_FILE"
  
  if [ "$MODEL" == "cbow" ]; then
    CBOW_FLAG=1
  else
    CBOW_FLAG=0
  fi

  log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
    -cbow "$CBOW_FLAG" -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
    -threads 20 -binary 1 -iter "$ITER" -min-count 10

  echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/questions-words.txt | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/msr.txt | tee -a "$LOG_FILE"

  echo "✔ Done: $OUTPUT_FILE"
  echo ""
done
