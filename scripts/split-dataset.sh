#!/bin/bash

# ./split_units.sh ../data/data.txt 240K 480M 6G

INPUT=$1
WORDS=("$@")

python ../run/split_dataset.py --input "$INPUT" "$WORDS[@]"