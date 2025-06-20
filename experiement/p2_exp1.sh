#!/bin/bash

# ./p2-exp1.sh

# Manually set parameters
GRAM=2
PHRASE_THRESHOLD=100
echo "Running with GRAM=$GRAM, PHRASE_THRESHOLD=$PHRASE_THRESHOLD"
echo "Before running this script, make sure you have created the phrase dataset using create-phrase.sh."
read -p "Press [Enter] to continue or Ctrl+C to exit..."


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


#!/bin/bash

# 공통 설정
DATASET="../data/14b.txt"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
BASE_OUTPUT_DIR="../output/p2_exp1_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

# 데이터셋 분할
bash ../scripts/split-dataset.sh "$DATASET" 6B

# 조합 리스트 (형식: "iter dim size model")
#The results show that while Negative Sampling achieves a respectable accuracy even with k = 5, using k = 15 achieves considerably better performance
combinations=(
  "1 1000 6B skip-gram 15 1e-5"
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
  fi

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
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 400000 < ../data/questions-words.txt 
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 1000000 < ../data/questions-phrases.txt 

  echo "✔ Done: $OUTPUT_FILE"
  echo ""
done
