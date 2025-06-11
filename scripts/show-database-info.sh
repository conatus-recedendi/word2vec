#!/bin/bash

# ./show-database-info.sh data.txt data2.txt

for i in "$@"; do
  python ../run/show_dataset_info.py --file $1 | touch "../output/${i%}.info" | tee "../output/${i%}.info"
done
