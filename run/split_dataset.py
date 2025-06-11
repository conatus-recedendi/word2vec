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

    with open(input_path, "r", encoding="utf-8") as f:
        word_gen = read_words_from_stream(f)
        for i, word_limit in enumerate(units):
            unit_str = unit_args[i]
            output_path = f"../data/data_{unit_str}.txt"

            if os.path.exists(output_path):
                print(f"Skipped {output_path} (already exists)")
                # Skip words to maintain pointer
                for _ in range(word_limit):
                    try:
                        next(word_gen)
                    except StopIteration:
                        return
                continue

            with open(output_path, "w", encoding="utf-8") as out:
                count = 0
                for _ in range(word_limit):
                    try:
                        word = next(word_gen)
                        out.write(word + " ")
                        count += 1
                    except StopIteration:
                        break
                print(f"Saved {output_path} ({count} words)")


if __name__ == "__main__":
    main()
