import argparse
import os
import re
from datasets import load_dataset

data_dir = "../data"


def preprocess(size="1000"):
    word_buf = []
    idx = 0

    with open(f"{data_dir}/openwebtext-{size}", "r", encoding="utf-8") as fin, open(
        f"{data_dir}/openwebtext-{size}-preprocessed", "w", encoding="utf-8"
    ) as fout:

        while True:
            chunk = fin.read(1024 * 1024)  # 1MB씩 읽기
            if not chunk:
                break

            for char in chunk:
                if idx % int(100 * 1e6) == 0:
                    print(f"Preprocessing {idx} characters...")

                if char.isspace():
                    if word_buf:
                        word = "".join(word_buf)
                        if re.fullmatch(r"[a-zA-Z0-9]+", word):
                            fout.write(word.lower() + " ")
                        word_buf = []
                else:
                    word_buf.append(char)

                idx += 1

        # 마지막에 남은 단어 처리
        if word_buf:
            word = "".join(word_buf)
            if re.fullmatch(r"[a-zA-Z0-9]+", word):
                fout.write(word.lower() + " ")

    print("Preprocessing complete.")


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
