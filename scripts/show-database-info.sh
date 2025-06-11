#!/bin/bash

# ./show-database-info.sh data.txt data2.txt

for i in "$@"; do
    if [ ! -f "$i" ]; then
        echo "File not found: $i"
        exit 1
    fi
  python ../run/show_dataset_info.py --file ../data/$1 | touch "../output/${i%}.info" | tee "../output/${i%}.info"
done
