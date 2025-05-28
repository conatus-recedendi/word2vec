#!/bin/bash

SIZE=1000000
python ../run/load_openwebtext.py --size $SIZE

python ../run/preprocess.py --size  $SIZE