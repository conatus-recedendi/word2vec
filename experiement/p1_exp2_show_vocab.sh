#!/bin/bash

# bash ./p1_exp2_show_vocab.sh ../data/14b_783M.txt ../data/14b_24M.txt


python ../run/p1_exp2_show_vocab.py --file1 "$1" --file2 "$2" --topk 30000