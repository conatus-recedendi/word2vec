#!/bin/bash

# bash ./p1_exp3 ../output/p1_table5_20250627_0000

# p1_table5 에서 "Acccuracy is reported on the full semantic-syntatic data set"이라고 해서 threshold 완전 제거
#!/bin/bash


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

DATASET="../data/14b.txt"

TIMESTAMP=$(date +"%Y%m%d_%H%M")

BASE_OUTPUT_DIR="../output/p1_exp3_${TIMESTAMP}"
mkdir -p "$BASE_OUTPUT_DIR"

REF_OUTPUT_DIR=$1


for combo in "${combinations[@]}"; do
  read ITER DIM SIZE MODEL <<< "$combo"
  
  INPUT_FILE="../data/14b_${SIZE}.txt"
  if [ ! -f "$INPUT_FILE" ]; then
    echo "[SKIP] $INPUT_FILE not found."
    continue
  fi

  OUTPUT_FILE="${REF_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.bin"
  LOG_FILE="${BASE_OUTPUT_DIR}/${MODEL}_${SIZE}_${DIM}d_iter${ITER}.log"
  
  echo "▶ Training Word2Vec ($MODEL) on $INPUT_FILE with dim=$DIM, iter=$ITER..." | tee -a "$LOG_FILE"
  
  if [ "$MODEL" == "cbow" ]; then
    CBOW_FLAG=1
  else
    CBOW_FLAG=0
  fi
  
  # log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
  #   -cbow "$CBOW_FLAG" -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
  #   -threads 20 -binary 1 -iter "$ITER" -min-count 10

  echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
  log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" < ../data/questions-words.txt

  echo "✔ Done: $OUTPUT_FILE"
  echo ""
done

# # bash ../scripts/split-dataset.sh "$DATASET" "${TRAINING_SIZES[@]}"
# # 각 조합에 대해 반복
# for DIM in "${DIMENSIONS[@]}"; do
#   for SIZE in "${TRAINING_SIZES[@]}"; do
#     INPUT_FILE="../data/14b_${SIZE}.txt"
    
#     OUTPUT_FILE="${REF_OUTPUT_DIR}/${SIZE}_${DIM}d.bin"
#     LOG_FILE="${BASE_OUTPUT_DIR}/${SIZE}_${DIM}d.log"
    
#     if [ ! -f "$INPUT_FILE" ]; then
#       echo "[SKIP] $INPUT_FILE not found." | tee -a "$LOG_FILE"
#       continue
#     fi

#     if [ ! -f "$OUTPUT_FILE" ]; then
#       echo "[SKIP] $OUTPUT_FILE not found." | tee -a "$LOG_FILE"
#       continue
#     fi

#     # echo "▶ Training Word2Vec on $INPUT_FILE with dimension $DIM..." | tee -a "$LOG_FILE"
#     # log_time "$LOG_FILE" ../bin/word2vec -train "$INPUT_FILE" -output "$OUTPUT_FILE" \
#     #   -cbow 1 -size "$DIM" -window 10 -negative 0 -hs 1 -sample 0 \
#     #   -threads 20 -binary 1 -iter 3 -min-count 10

#     echo "▶ Evaluating accuracy for $OUTPUT_FILE" | tee -a "$LOG_FILE"
#     log_time "$LOG_FILE" ../bin/compute-accuracy "$OUTPUT_FILE" 400000 < ../data/questions-words.txt

#     echo "✔ Done: $OUTPUT_FILE"
#     echo ""
#   done
# done