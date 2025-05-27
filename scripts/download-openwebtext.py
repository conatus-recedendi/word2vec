# coding: utf-8

from datasets import load_dataset


def load_openwebtext(size="65000000"):
    dataset = load_dataset(
        "openwebtext",
        split=f"train[:{size}]",
        trust_remote_code=True,
    )  # 전체 dataset 하나뿐
    texts = dataset["text"]
    return texts


if __name__ == "__main__":
    # main(size="65000000")
    print("Loading OpenWebText... (1000)")
    texts = load_openwebtext(size="1000")
    print("size: ", len(texts))
    print("Saving OpenWebText to ./data/openwebtext-l1000")
    with open("./data/openwebtext-l1000", "w", encoding="utf-8") as f:
        for text in texts:
            f.write(text + " ")

    # analysis(size="1000")
    # analysis(size="2000")
    # analysis(size="5000")
    # analysis(size="12000")
