# coding: utf-8

from datasets import load_dataset
import re
import argparse


def load_openwebtext(size="65000000"):
    dataset = load_dataset(
        "openwebtext",
        split=f"train[:{size}]",
        trust_remote_code=True,
    )  # 전체 dataset 하나뿐
    texts = dataset["text"]
    return texts


def tokenize(texts):
    words = []
    for line in texts:
        line = line.strip().replace("\n", " ")  # + " <eos>"
        words.extend(line.split())
    return words


def preprocess(words):
    # 알파벳, 숫자, 또는 알파벳+숫자로 이루어진 단어만 남김 (예: "conversation00" 포함)
    words = [w for w in words if re.fullmatch(r"[a-zA-Z0-9]+", w)]
    words = [w.lower() for w in words]
    return words


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--size",
        type=str,
        default="1000",
        help="Number of samples to load from OpenWebText",
    )
    args = parser.parse_args()
    size = args.size
    print(f"Loading OpenWebText... ({size})")
    texts = load_openwebtext(size)
    words = tokenize(texts)
    words = preprocess(words)
    print("size: ", len(texts))
    print(f"Saving OpenWebText to ../data/openwebtext-l{size}")
    # create file and
    with open(f"../data/openwebtext-l{size}", "w+", encoding="utf-8") as f:
        for text in words:
            f.write(text + " ")

    # analysis(size="1000")
    # analysis(size="2000")
    # analysis(size="5000")
    # analysis(size="12000")
