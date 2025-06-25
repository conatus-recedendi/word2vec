#!/bin/bash

# bash ./download-data.sh --output data.txt news2012 news2013 1blm umbc enwiki

# 기본 출력 파일은 data.txt
OUTPUT_FILE="data.txt"
DATASETS=()

# 인자 파싱: --output 옵션과 나머지 데이터 인자 분리
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      shift
      OUTPUT_FILE="$1"
      ;;
    news2012|news2013|1blm|umbc|enwiki)
      DATASETS+=("$1")
      ;;
    *)
      echo "Unknown argument: $1"
      ;;
  esac
  shift
done

# normalize 함수 정의
normalize_text() {
  awk '{print tolower($0);}' | sed -e "s/’/'/g" -e "s/′/'/g" -e "s/''/ /g" -e "s/'/ ' /g" -e "s/“/\"/g" -e "s/”/\"/g" \
  -e 's/"/ " /g' -e 's/\./ \. /g' -e 's/<br \/>/ /g' -e 's/, / , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' \
  -e 's/\?/ \? /g' -e 's/\;/ /g' -e 's/\:/ /g' -e 's/-/ - /g' -e 's/=/ /g' -e 's/*/ /g' -e 's/|/ /g' \
  -e 's/«/ /g' | tr 0-9 " "
}

cd ../data/

append_output() {
  normalize_text < "$1" >> "$OUTPUT_FILE"
}

process_news2012() {
  if [ ! -f news.2012.en.shuffled ]; then
    if [ ! -f news.2012.en.shuffled.gz ]; then
      wget http://www.statmt.org/wmt14/training-monolingual-news-crawl/news.2012.en.shuffled.gz
    fi
    gzip -d -f news.2012.en.shuffled.gz
  fi
  append_output news.2012.en.shuffled
}

process_news2013() {
  if [ ! -f news.2013.en.shuffled ]; then
    if [ ! -f news.2013.en.shuffled.gz ]; then
      wget http://www.statmt.org/wmt14/training-monolingual-news-crawl/news.2013.en.shuffled.gz
    fi
    gzip -d -f news.2013.en.shuffled.gz
  fi
  append_output news.2013.en.shuffled
}

process_1blm() {
  if [ ! -d 1-billion-word-language-modeling-benchmark-r13output ]; then
    if [ ! -f 1-billion-word-language-modeling-benchmark-r13output.tar.gz ]; then
      wget http://www.statmt.org/lm-benchmark/1-billion-word-language-modeling-benchmark-r13output.tar.gz
    fi
    tar -xvf 1-billion-word-language-modeling-benchmark-r13output.tar.gz
  fi
  for i in 1-billion-word-language-modeling-benchmark-r13output/training-monolingual.tokenized.shuffled/*; do
    append_output "$i"
  done
}

process_umbc() {
  if [ ! -d webbase_all ]; then
    if [ ! -f umbc_webbase_corpus.tar.gz ]; then
      wget http://ebiquity.umbc.edu/redirect/to/resource/id/351/UMBC-webbase-corpus
      mv UMBC-webbase-corpus umbc_webbase_corpus.tar.gz
    fi
    tar -zxvf umbc_webbase_corpus.tar.gz webbase_all/*.txt
  fi
  for i in webbase_all/*.txt; do
    append_output "$i"
  done
}

process_enwiki() {
  if [ ! -f enwiki-latest-pages-articles.xml.bz2 ]; then
    wget --user-agent="DILab/1.0" --referer="https://dumps.wikimedia.org/enwiki/latest/" https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2
  fi
  bzip2 -c -d enwiki-latest-pages-articles.xml.bz2 | awk '{print tolower($0);}' | perl -e '
  $/=">";
  while (<>) {
    if (/<text /) {$text=1;}
    if (/#redirect/i) {$text=0;}
    if ($text) {
      if (/<\/text>/) {$text=0;}
      s/<.*>//;
      s/&amp;/&/g;
      s/&lt;/</g;
      s/&gt;/>/g;
      s/<ref[^<]*<\/ref>//g;
      s/<[^>]*>//g;
      s/\[http:[^] ]*/[/g;
      s/\|thumb//ig;
      s/\|left//ig;
      s/\|right//ig;
      s/\|\d+px//ig;
      s/\[\[image:[^\[\]]*\|//ig;
      s/\[\[category:([^|\]]*)[^]]*\]\]/[[$1]]/ig;
      s/\[\[[a-z\-]*:[^\]]*\]\]//g;
      s/\[\[[^\|\]]*\|/[[/g;
      s/\{\{[^}]*\}\}//g;                # {{...}} 제거
      s/\{[^}]*\}//g;                    # {...} 제거
      s/\[//g;
      s/\]//g;
      s/&[^;]*;/ /g;
      $_=" $_ ";
      chop;
      print $_;
    }
  }' | normalize_text | awk '{if (NF>1) print;}' >> "$OUTPUT_FILE"
}

# 실행
for dataset in "${DATASETS[@]}"; do
  case $dataset in
    news2012) process_news2012 ;;
    news2013) process_news2013 ;;
    1blm) process_1blm ;;
    umbc) process_umbc ;;
    enwiki) process_enwiki ;;
    *) echo "Unknown dataset: $dataset" ;;
  esac
done
