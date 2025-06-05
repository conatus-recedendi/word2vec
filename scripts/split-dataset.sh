#!/bin/bash

# ./split_units.sh 240K 480M 6G

INPUT="../data/data.txt"
WORDS=($(cat $INPUT))
TOTAL=${#WORDS[@]}
START=0

for UNIT in "$@"; do
    # 숫자와 단위 분리
    VALUE=$(echo "$UNIT" | sed -E 's/[^0-9.]//g')
    SUFFIX=$(echo "$UNIT" | sed -E 's/[0-9.]//g' | tr '[:lower:]' '[:upper:]')

    # 단위 변환
    case "$SUFFIX" in
        K) MULTIPLIER=1000 ;;
        M) MULTIPLIER=1000000 ;;
        G) MULTIPLIER=1000000000 ;;
        *) echo "Unknown unit: $SUFFIX"; exit 1 ;;
    esac

    SIZE=$(echo "$VALUE * $MULTIPLIER" | bc | cut -d'.' -f1)
    END=$((START + SIZE))
    if [ $END -gt $TOTAL ]; then
        END=$TOTAL
    fi

    OUTPUT="../data/data_${VALUE}${SUFFIX}.txt"
    if [ -f "$OUTPUT" ]; then
        echo "Skipped $OUTPUT (already exists)"
    else
        echo "${WORDS[@]:$START:$((END - START))}" > "$OUTPUT"
        echo "Saved $OUTPUT ($((END - START)) words)"
    fi

    START=$END
    if [ $START -ge $TOTAL ]; then
        break
    fi
done
