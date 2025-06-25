#!/bin/bash

# 포함할 단어 배열 정의
WORDS=('unimpressive' 'quickest' 'weirdest' 'inconvenient' 'grandpa' 'coolest' 'smartest' 'dong' 'mango' 'unconvincing' 'pear' 'stepfather' 'donkey' 'unproductive' 'rial' 'darkest' 'widest' 'sweetest' 'impossibly' 'swam' 'stepmother' 'distasteful' 'unethical' 'hotter' 'lev' 'furiously' 'inventing' 'vanish' 'grandma' 'cheerfully' 'stepdaughter' 'slowest' 'groom' 'rupee' 'vanishing' 'swims' 'sharpest' 'warmest' 'pineapple' 'bananas' 'pears' 'shuffle' 'coldest' 'strangest')

# 파일 경로 지정
FILE="../data/questions-words.txt"

# 정규표현식 패턴 만들기 (단어들 OR 조건)
PATTERN=$(IFS='|'; echo "${WORDS[*]}")

# :로 시작하지 않는 줄 중에서 단어가 하나라도 포함된 줄 수 계산
grep -v '^:' "$FILE" | grep -Ew "$PATTERN" | wc -l
