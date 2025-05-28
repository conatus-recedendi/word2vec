import argparse
import os
import re
from datasets import load_dataset

data_dir = "../data"


def load_openwebtext(size="1000"):

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


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--size",
        type=str,
        default="1000",
        help="Number of samples to load from OpenWebText",
    )
    size = parser.parse_args().size
    load_openwebtext(size)  # Change size as needed
    # preprocess()  # Uncomment if you want to run the preprocessing step
