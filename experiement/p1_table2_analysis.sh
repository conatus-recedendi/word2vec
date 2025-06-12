#!/bin/bash

# 사용 예:
# ./parse_logs.sh ../output/p1_table2_20250612_0655 --keys size dim --pattern "Total accuracy:"

KEYS=()
PATTERN=""

LOG_FILE=$1
shift
cd $1



# 옵션 파싱
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --keys)
            shift
            IFS=',' read -ra KEYS <<< "$1"
            ;;
        --pattern)
            shift
            PATTERN="$1"
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

# 디렉토리 내 로그 파일을 순회
for file in *.log; do
    [[ -f "$file" ]] || continue

    # 파일명 파싱: ex) 24M_100d_iter10_ns5_s0.01_extra.log
    base="${file%.log}"
    
    # 기본 정보 추출 (dataset_size, dimension, optional Z)
    dataset_size=$(echo "$base" | cut -d'_' -f1)
    dimension=$(echo "$base" | cut -d'_' -f2)
    rest=$(echo "$base" | cut -d'_' -f3-)

    # Z 추출
    Z=""
    for key in "${KEYS[@]}"; do
        # key-value 추출
        if [[ "$rest" =~ ${key}([^_]+) ]]; then
            declare "$key"="${BASH_REMATCH[1]}"
        fi
    done

    # Z를 제거한 나머지를 Z로 간주
    temp="$dataset_size"_"$dimension"
    for key in "${KEYS[@]}"; do
        value=$(eval echo \$$key)
        temp="${temp}_${key}${value}"
    done
    Z="${base#$temp}"
    [[ "$Z" == "$base" ]] && Z=""

    # 로그 내 패턴 검색
    if [[ -n "$PATTERN" ]]; then
        match_line=$(grep -m 1 "$PATTERN" "$file")
    else
        match_line="(no pattern given)"
    fi

    # 결과 출력
    echo "{"
    echo "  \"file\": \"$file\","
    echo "  \"dataset_size\": \"$dataset_size\","
    echo "  \"dimension\": \"$dimension\","
    for key in "${KEYS[@]}"; do
        value=$(eval echo \$$key)
        echo "  \"$key\": \"$value\","
    done
    if [[ -n "$Z" ]]; then
        echo "  \"extra\": \"${Z#_}\","
    fi
    echo "  \"log_line\": \"${match_line//\"/\\\"}\""
    echo "}"
done
