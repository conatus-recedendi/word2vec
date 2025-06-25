import argparse
from collections import Counter


def get_top_vocab(file_path, top_k=30000):
    with open(file_path, "r", encoding="utf-8") as f:
        words = f.read().split()
    counter = Counter(words)
    return set(word for word, _ in counter.most_common(top_k))


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
