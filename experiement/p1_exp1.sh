#!/bin/bash
 
# ./p1-exp1.sh ../output./p1_table5_20250613_0828/

# p1_table5에서 구한 binary 데이터를 가지고, auccraecy threshold 30K개만 측정한 실험



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
BASE_OUTPUT_DIR="../output/p1_exp1_${TIMESTAMP}"
REF_OUTPUT_FOLDER=$1

# 데이터셋 분할
# bash ../scripts/split-dataset.sh "$DATASET" 783M 1.6B

# 조합 리스트 (형식: "iter dim size model")
combinations=(
  "3 300 783M cbow"
  "3 300 783M skip-gram"
  "1 300 783M cbow"
  "1 300 1.6B cbow"
  "1 600 783M cbow"
  "1 300 783M skip-gram"
  "1 300 1.6B skip-gram"
  "1 600 783M skip-gram"
)

# 반복 실행
for combo in "${combinations[@]}"; do
  read ITER DIM SIZE MODEL <<< "$combo"
  
  INPUT_FILE="../data/14b_${SIZE}.txt"
  if [ ! -f "$INPUT_FILE" ]; then
    echo "[SKIP] $INPUT_FILE not found."
    continue
  fi

  OUTPUT_FILE="${REF_OUTPUT_FOLDER}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.bin"
  LOG_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.log"
  
  echo "▶ Training Word2Vec ($MODEL) on $INPUT_FILE with dim=$DIM, iter=$ITER..." | tee -a "$LOG_FILE"
  
  if [ "$MODEL" == "cbow" ]; then
    CBOW_FLAG=1
  else
    CBOW_FLAG=0
  fi

  if [ ! -f "$OUTPUT_FILE" ]; then
    echo "[ERROR] $OUTPUT_FILE not found. Training Word2Vec..." | tee -a "$LOG_FILE"
  fi



  # log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
  #   -cbow "$CBOW_FLAG" -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
  #   -threads 20 -binary 1 -iter "$ITER" -min-count 10

  echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/questions-words.txt 
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 30000 < ../data/msr.txt 

  echo "✔ Done: $OUTPUT_FILE"
  echo ""
done
