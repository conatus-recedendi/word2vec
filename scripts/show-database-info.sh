#!/bin/bash

# ./show-database-info.sh data.txt data2.txt

for i in "$@"; do
    if [ ! -f "$i" ]; then
        echo "File not found: $i"
        exit 1
    fi
  python ../run/show_dataset_info.py --file $1 | tee "info_${i%.txt}.txt"
done
