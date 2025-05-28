import argparse

data_dir = "../data"


def show_info(file_name):
    # show corpus/vocab/
    word_cnt = 0
    word_set = set()
    word_buf = []
    # dataset size, vocab size, corpus size
    with open(f"{data_dir}/{file_name}", "r", encoding="utf-8") as f:

        while True:
            char = f.read(1)
            if not char:
                break
            if char.isspace():
                word = "".join(word_buf)
                word_set.add(word)
                word_buf.clear()
                word_cnt += 1
            else:
                word_buf.append(char)

    print(f"Dataset file: {data_dir}/{file_name}")
    print(f"Total words in dataset: {word_cnt}")
    print(f"Unique words in dataset: {len(word_set)}")


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
