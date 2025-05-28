import argparse
import os
import re
from datasets import load_dataset

data_dir = "../data"


def preprocess(size="1000"):

    words = []
    word_buf = []

    with open(f"{data_dir}/openwebtext-{size}", "r", encoding="utf-8") as f:
        while True:
            chunk = f.read(1024 * 1024)  # 1MB씩 읽기
            if not chunk:
                break

            for ch in chunk:
                if ch.isspace():
                    if word_buf:
                        word = "".join(word_buf)
                        if re.fullmatch(r"[a-zA-Z0-9]+", word):
                            words.append(word.lower())
                        word_buf = []  # 버퍼 초기화 (메모리 해제 효과)
                else:
                    word_buf.append(ch)

        # 마지막 단어 처리 (파일 끝에 공백 없을 경우)
        if word_buf:
            word = "".join(word_buf)
            if re.fullmatch(r"[a-zA-Z0-9]+", word):
                words.append(word.lower())

    print(f"Preprocessed words size: {len(words)}")
    with open(
        f"{data_dir}/openwebtext-{size}-preprocessed", "w+", encoding="utf-8"
    ) as f:
        for word in words:
            f.write(word + " ")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--size",
        type=str,
        default="1000",
        help="Number of samples to preprocess from OpenWebText",
    )
    size = parser.parse_args().size

    preprocess(size)  # Uncomment if you want to run the preprocessing step
