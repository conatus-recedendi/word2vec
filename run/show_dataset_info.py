import argparse

data_dir = "../data"


def show_info(file_name):
    # show corpus/vocab/
    word_cnt = 0
    word_set = set()
    # dataset size, vocab size, corpus size
    with open(f"{data_dir}/{file_name}", "r", encoding="utf-8") as f:
        buf = ""
        # what file size
        file_size = f.seek(0, 2)

        f.seek(0)  # reset file pointer to the beginning
        while True:

            words = f.read(4096)  # 4KB
            # if read 14b.txt(93Gb), it will take  93 * 1024 * 1024 / 4096 = 24,576 iterations
            if not words:
                break
            if f.tell() % (file_size // 10) == 0:
                print(
                    f"[show_dataset_info.py] Processed {f.tell() / file_size:.2%} of the file."
                )

            words = buf + words

            buf = words[words.rfind(" ") + 1 :]  # keep the last word in the buffer
            words = words[: -len(buf)]

            words = words.split()
            for word in words:
                if word.strip():
                    word_set.add(word)
                    word_cnt += 1

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
