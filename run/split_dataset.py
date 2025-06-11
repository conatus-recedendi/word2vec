import argparse
import os


def parse_unit(unit_str):
    unit_str = unit_str.upper()
    num = float("".join(c for c in unit_str if c.isdigit() or c == "."))
    suffix = "".join(c for c in unit_str if not c.isdigit() and c != ".")
    if suffix == "K":
        return int(num * 1_000)
    elif suffix == "M":
        return int(num * 1_000_000)
    elif suffix == "G":
        return int(num * 1_000_000_000)
    else:
        raise ValueError(f"Unknown unit: {suffix}")


def read_words_from_stream(f):
    buf = ""
    while True:
        chunk = f.read(4096)
        if not chunk:
            break
        buf += chunk
        while True:
            split = buf.split(" ", 1)
            if len(split) < 2:
                break
            yield split[0]
            buf = split[1]
    if buf.strip():
        for word in buf.strip().split():
            yield word


def main():
    parser = argparse.ArgumentParser(
        description="Split a single-line word file into parts by word units (K, M, G)."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="Input file path (must be a single-line word stream)",
    )
    parser.add_argument(
        "units", nargs="+", help="List of units to split (e.g., 240K 480M 6G)"
    )
    args = parser.parse_args()

    input_path = args.input
    unit_args = args.units
    units = [parse_unit(u) for u in unit_args]
    units_flag = [0] * len(units)

    for i, unit in enumerate(units):
        output_path = f"../data/data_{unit_args[i]}.txt"
        if os.path.exists(output_path):
            units_flag[i] = 1
            print(f"[run/split_dataset.py] {output_path} already exists, skipping.")
        else:
            print(f"[run/split_dataset.py] {output_path} does not exist, will create.")

    with open(input_path, "r", encoding="utf-8") as f:
        word_gen = read_words_from_stream(f)
        # until word_gen is done or all units are processed
        count = 0
        while True:
            # Skip empty words
            try:
                word = next(word_gen)
                count += word.count(" ") + 1  # Count words in the current word
            except StopIteration:
                break

            if units_flag == [1] * len(units):
                print("[run/split_dataset.py] All units processed, exiting.")
                break

            # Skip empty words
            if not word.strip():

                continue

            for i, word_limit in enumerate(units):
                unit_str = unit_args[i]
                output_path = f"../data/data_{unit_str}.txt"

                with open(output_path, "w", encoding="utf-8") as out:

                    # Write words until the limit is reached
                    if count < word_limit:
                        units_flag[i] = 1
                        continue
                    try:
                        out.write(word + " ")
                    except StopIteration:
                        break


if __name__ == "__main__":
    main()
