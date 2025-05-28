import re
import argparse
from datasets import load_dataset

data_dir = "../data"


def load_openwebtext():

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--size",
        type=str,
        default="1000",
        help="Number of samples to load from OpenWebText",
    )
    size = parser.parse_args().size
    dataset = load_dataset(
        "openwebtext",
        split=f"train[:{size}]",
        trust_remote_code=True,
    )  # 전체 dataset 하나뿐
    texts = dataset["text"]

    open(f"{data_dir}/openwebtext-{size}", "w+", encoding="utf-8").close()  # 파일 생성
    with open(f"{data_dir}/openwebtext-{size}", "w+", encoding="utf-8") as f:
        for line in texts:
            line = line.strip().replace("\n", " ")
            f.write(line + " ")
    print(f"OpenWebText loaded and saved to {data_dir}/openwebtext-{size}")
    print(f"dataset sentence Size of OpenWebText: {len(texts)}")


def preprocess():

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--size",
        type=str,
        default=size,
        help="Number of samples to preprocess from OpenWebText",
    )
    size = parser.parse_args().size
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
