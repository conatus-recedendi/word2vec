import argparse
from collections import Counter
import sys


def read_words_from_stream(
    f,
):
    buf = ""
    while True:
        chunk = f.read(4096)
        if not chunk:
            break
        chunk = buf + chunk

        buf = chunk[chunk.rfind(" ") + 1 :]  # keep the last word in the buffer
        chunk = chunk[: -len(buf)]

        yield chunk  # output words

    if buf.strip():
        yield buf.strip()  # yield any remaining words in the buffer


def get_top_vocab(file_path, top_k=30000):
    word_cnt
    word_counter = Counter()  # Counter to keep track of word frequencies
    with open(file_path, "r", encoding="utf-8") as f:
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
    return set(word for word, _ in word_counter.most_common(top_k))


def main():
    parser = argparse.ArgumentParser(
        description="Compare top-K vocabularies from two files."
    )
    parser.add_argument(
        "--file1", type=str, required=True, help="Path to the first file"
    )
    parser.add_argument(
        "--file2", type=str, required=True, help="Path to the second file"
    )
    parser.add_argument(
        "--topk",
        type=int,
        default=30000,
        help="Number of top frequent words to consider",
    )
    args = parser.parse_args()

    vocab1 = get_top_vocab(args.file1, args.topk)
    vocab2 = get_top_vocab(args.file2, args.topk)

    only_in_file1 = vocab1 - vocab2
    only_in_file2 = vocab2 - vocab1

    print(f"▶ {args.file1}에만 있는 단어 수: {len(only_in_file1)}")
    print(f"  예시: {list(only_in_file1)[:10]}")
    print()
    print(f"▶ {args.file2}에만 있는 단어 수: {len(only_in_file2)}")
    print(f"  예시: {list(only_in_file2)[:10]}")


if __name__ == "__main__":
    main()
