import argparse

data_dir = "../data"


def show_info(file_name):
    # show corpus/vocab/
    # dataset size, vocab size, corpus size
    with open(f"{data_dir}/{file_name}", "r", encoding="utf-8") as f:
        words = f.read().split()
    print(f"Dataset file: {data_dir}/{file_name}")
    print(f"Total words in dataset: {len(words)}")
    print(f"Unique words in dataset: {len(set(words))}")


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()

    arg_parser.add_argument(
        "--file",
        type=str,
        default="openwebtext-1000",
        help="File name to save the OpenWebText dataset",
    )
    args = arg_parser.parse_args()
    file_name = args.file
    show_info(file_name)
