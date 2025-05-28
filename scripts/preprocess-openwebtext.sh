#!/bin/sh

SIZE = 1000000
python ../run/dataset.py --function load_openwebtext --size $SIZE

python ../run/dataset.py  --function preprocess --size  $SIZE