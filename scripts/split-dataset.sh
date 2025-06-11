#!/bin/bash

# ./split_units.sh ../data/data.txt 240K 480M 6G

INPUT=$1
WORDS=($(cat $INPUT))
TOTAL=${#WORDS[@]}
START=0

python ../run/split_units.py --input "$INPUT" --total "$TOTAL" --start "$START" --end 240000