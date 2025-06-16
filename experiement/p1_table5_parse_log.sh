#!/bin/bash

# 사용 예:
# total accuracy 
# bash ./p1_table5_parse_log.sh ../output/p1_table5_20250613_0828 --keys model,size,dim,iter --pattern "Total accuracy:" --append
# questions seen / total
# bash ./p1_table5_parse_log.sh ../output/p1_table5_20250613_0828 --keys model,size,dim,iter  --pattern "Questions seen / total:"
# time elapsed
# bash ./p1_table5_parse_log.sh ../output/p1_table5_20250613_0828 --keys model,size,dim,iter --pattern "Time elapsed:" --append


# caution! only for p1_table2 logs

KEYS=()
PATTERN=""
APPEND=false
LOG_FILE=$1
cd "$1" || { echo "Directory not found: $1"; exit 1; }
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
        --append)
            APPEND=true
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

    for i in "${!parts[@]}"; do
        if [[ $i -lt ${#KEYS[@]} ]]; then
            key="${KEYS[$i]}"
            values["$key"]="${parts[$i]}"
        else
            extra_parts+=("${parts[$i]}")
        fi
    done

    # 로그 라인 검색
    if [[ -n "$PATTERN" ]]; then
        if $APPEND; then
            match_lines=$(grep "$PATTERN" "$file" | sed ':a;N;$!ba;s/\n/\\n/g')
        else
            match_lines=$(grep "$PATTERN" "$file" | tail -n 1)
        fi
    else
        match_lines=""
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
    echo "  \"log_line\": \"${match_lines//\"/\\\"}\""
    echo "}"
done
