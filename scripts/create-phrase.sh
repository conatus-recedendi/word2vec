#!bin/bash

THRESHOLD=( 200 100 )
DATASET="../data/data.txt"
STEP=1

for i in "${THRESHOLD[@]}"; do
    echo "Running word2phrase with threshold $i"
    if [ STEP == 1 ]; then
      echo "Creating phrases with threshold $i"
      ./word2phrase -train "$DATASET" -output data_phrase_step=${STEP}_th=${i}.txt -threshold "$i" -debug 2
    else
      echo "Creating phrases with threshold $i (step $STEP)"
      ./word2phrase -train data_phrase_step=$((STEP - 1))_th=${THRESHOLD[STEP - 2]}.txt -output data_phrase_step=${STEP}_th=${i}.txt -threshold "$i" -debug 2
    fi
    STEP=$((STEP + 1))
done
# ./word2phrase -train data.txt -output data-phrase.txt -threshold 200 -debug 2
# ./word2phrase -train data-phrase.txt -output data-phrase2.txt -threshold 100 -debug 2