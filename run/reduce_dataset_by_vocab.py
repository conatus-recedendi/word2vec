import sys
import argparse
from collections import Counter


def main():
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument(
        "--file",
        type=str,
        required=True,
        help="Path to the file containing words",
    )
    arg_parser.add_argument(
        "--output",
        type=str,
        default="reduced_dataset.txt",
        help="Path to save the reduced dataset",
    )
    arg_parser.add_argument(
        "--threshold",
        type=int,
        default=1_000_000,
        help="Threshold for the number of words to keep in the dataset",
    )
    args = arg_parser.parse_args()
    file_path = args.file
    threshold = args.threshold  # 100 million words
    output_path = args.output

    word_cnt = 0
    word_counter = Counter()
    with open(f"{file_path}", "r", encoding="utf-8") as f:
        buf = ""
        # what file size
        file_size = f.seek(0, 2)

        f.seek(0)  # reset file pointer to the beginning
        while True:

            words = f.read(4096)  # 4KB
            # if read 14b.txt(93Gb), it will take  93 * 1024 * 1024 / 4096 = 24,576 iterations
            if not words:
                break

            # show percentages
            percent = f.tell() / file_size * 100
            sys.stdout.write(
                f"\rProcessing {file_path}: {percent:.2f}% complete, "
                f"Total words: {word_cnt}, Unique words: {len(word_counter)}"
            )
            sys.stdout.flush()

            words = buf + words

            buf = words[words.rfind(" ") + 1 :]  # keep the last word in the buffer
            words = words[: -len(buf)]

            words = words.split()
            for word in words:
                if word.strip():
                    word_counter[word] += 1

                    word_cnt += 1

    # reduce until threshold
    print(f"\nTotal words in dataset: {word_cnt}")
    print(f"Unique words in dataset: {len(word_counter)}")
    print(f"Reducing dataset to {threshold} words...")
    reduced_words = []
    for word, count in word_counter.most_common():
        if len(reduced_words) < threshold:
            reduced_words.append(word)
        else:
            break

    # write files by reduced vocab

    with open(output_path, "w", encoding="utf-8") as out_f:
        with open(f"{file_path}", "r", encoding="utf-8") as f:
            buf = ""
            # what file size
            file_size = f.seek(0, 2)

            f.seek(0)  # reset file pointer to the beginning
            while True:

                words = f.read(4096)  # 4KB
                # if read 14b.txt(93Gb), it will take  93 * 1024 * 1024 / 4096 = 24,576 iterations
                if not words:
                    break

                # show percentages
                percent = f.tell() / file_size * 100
                sys.stdout.write(
                    f"\rProcessing {file_path}: {percent:.2f}% complete, "
                    f"Total words: {word_cnt}, Unique words: {len(word_counter)}"
                )
                sys.stdout.flush()

                words = buf + words

                buf = words[words.rfind(" ") + 1 :]  # keep the last word in the buffer
                words = words[: -len(buf)]

                words = words.split()
                for word in words:
                    if word.strip():
                        word_counter[word] += 1

                        word_cnt += 1
                        if word in reduced_words:
                            out_f.write(word + " ")


if __name__ == "__main__":
    main()
