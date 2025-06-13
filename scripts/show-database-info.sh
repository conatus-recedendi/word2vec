#!/bin/bash

# ./show-database-info.sh data.txt data2.txt

for i in "$@"; do
  touch "../output/${i%}.info"
  python ../run/show_dataset_info.py --file ${i%}  | tee /dev/tty | awk 'index($0, "\r") == 0' >> "../output/${i%}.info"
done
