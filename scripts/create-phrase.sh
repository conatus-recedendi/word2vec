#!bin/bash
# bash ./create-phrase.sh

#  p2_table3.sh: threhshold 200, 100, 50, size=1B
#  p2_exp1.sh: threhshold 200, 100, 50, size=6B
THRESHOLD=( 200 100 50 )
SIZE=1B # 
DATASET="../data/14b_$SIZE.txt"
STEP=2 # bi-gram. 3 means tri-gram ...

for i in "${THRESHOLD[@]}"; do
    echo "Running word2phrase with threshold $i"
    if [ "$STEP" -eq 2 ]; then
      echo "Creating phrases with threshold $i"
      ../bin/word2phrase -train "$DATASET" -output ../data/data_phrase_gram=${STEP}_th=${i}_size=${SIZE}.txt -threshold "$i" -debug 2
    else
      PREV_STEP=$((STEP - 1))
      PREV_THRESHOLD=${THRESHOLD[$((STEP - 3))]}
      echo "Creating phrases with threshold $i (step $STEP)"
      ../bin/word2phrase -train ../data/data_phrase_gram=${PREV_STEP}_th=${PREV_THRESHOLD}_size=${SIZE}.txt \
          -output ../data/data_phrase_gram=${STEP}_th=${i}_size=${SIZE}.txt \
          -threshold "$i" -debug 2
    fi
    STEP=$((STEP + 1))
done
# ./word2phrase -train data.txt -output data-phrase.txt -threshold 200 -debug 2
# ./word2phrase -train data-phrase.txt -output data-phrase2.txt -threshold 100 -debug 2