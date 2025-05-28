import argparse

import os

data_dir = "../data"


def read_words_by_sizes(input_path, sizes):

    sizes = sorted(sizes)

    size_idx = 0
    current_size = sizes[size_idx]
    word_buf = []
    word_count = 0
    words_accum = []

    with open(input_path, "r", encoding="utf-8") as f:
        while True:
            char = f.read(1)
            if not char:
                break

            if char.isspace():
                if word_buf:
                    word = "".join(word_buf)
                    words_accum.append(word)
                    word_buf.clear()
                    word_count += 1

                    if word_count % (current_size[-1] / 10) == 0:
                        print(
                            f"Accumulated {word_count} words... ({current_size} target size)"
                        )

                    # 현재 목표 크기에 도달했을 때만 저장
                    if word_count == current_size:
                        out_path = os.path.join(data_dir, f"words_{current_size}")
                        with open(out_path, "w", encoding="utf-8") as fout:
                            fout.write(" ".join(words_accum))
                        print(f"Saved {current_size} words to {out_path}")
                        words_accum.clear()

                        size_idx += 1
                        if size_idx >= len(sizes):
                            break
                        current_size = sizes[size_idx]
            else:
                word_buf.append(char)


if __name__ == "__main__":
    args = argparse.ArgumentParser()
    args.add_argument(
        "--input_path",
        type=str,
        default="openwebtext-2000000-preprocessed",
        help="Path to the input file containing preprocessed words",
    )
    args.add_argument(
        "--sizes",
        type=int,
        nargs="+",
        default=[
            24 * 10e6,
            49 * 10e6,
            98 * 10e6,
            196 * 10e6,
            391 * 10e6,
            783 * 10e6,
            1.6 * 10e9,
            6.0 * 10e9,
            37 * 10e6,
            320 * 10e6,
            990 * 10e6,
        ],
        help="List of sizes to read words by",
    )

    args = args.parse_args()
    input_path = os.path.join(data_dir, args.input_path)
    sizes = args.sizes

    read_words_by_sizes(input_path, sizes)
