#!/bin/bash

# 사용 예:
# ./parse_logs.sh ../output/p1_table2_20250612_0655 --keys size dim --pattern "Total accuracy:"


KEYS=()
PATTERN=""
LOG_FILE=$1
cd $1
shift

# 인자 파싱
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

# 파일 순회
for file in *.log; do
    [[ -f "$file" ]] || continue

    filename="${file%.log}"  # 확장자 제거
    IFS='_' read -ra parts <<< "$filename"

    declare -A values=()
    extra_parts=()

    # 각 조각을 키와 매핑
    for part in "${parts[@]}"; do
        matched=false
        for key in "${KEYS[@]}"; do
            if [[ "$part" == ${key}* ]]; then
                value="${part#${key}}"
                values["$key"]="$value"
                matched=true
                break
            fi
        done
        if ! $matched; then
            extra_parts+=("$part")
        fi
    done

    # 로그 라인 검색
    if [[ -n "$PATTERN" ]]; then
        match_line=$(grep -m 1 "$PATTERN" "$file")
    else
        match_line=""
    fi

    # JSON 출력
    echo "{"
    echo "  \"file\": \"$file\","
    for key in "${KEYS[@]}"; do
        echo "  \"$key\": \"${values[$key]}\","
    done
    if [[ ${#extra_parts[@]} -gt 0 ]]; then
        echo "  \"extra\": \"${extra_parts[*]}\","
    fi
    echo "  \"log_line\": \"${match_line//\"/\\\"}\""
    echo "}"
done
