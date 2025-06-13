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
    elif suffix == "B" | suffix == "G":
        return int(num * 1_000_000_000)
    else:
        raise ValueError(f"Unknown unit: {suffix}")


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
    unit_args = args.units[0].split(" ")
    units = [{"value": parse_unit(u), "unit_args": u} for u in unit_args]

    removed_units = []
    for i, unit in enumerate(units):
        output_path = f"../data/14b_{unit_args[i]}.txt"
        if os.path.exists(output_path):
            removed_units.append(unit)
            print(f"[run/split_dataset.py] {output_path} already exists, skipping.")
        else:
            print(f"[run/split_dataset.py] {output_path} does not exist, will create.")

    for unit in removed_units:
        units.remove(unit)
    print(units)
    with open(input_path, "r", encoding="utf-8") as f:
        word_gen = read_words_from_stream(f)
        # until word_gen is done or all units are processed
        count = 0  # Total word count across all units
        while True:
            # Skip empty words
            try:
                words = next(word_gen)  # "apple banana cherry"
                count += len(words.split())
            except StopIteration:
                break

            if len(units) == 0:
                print("[run/split_dataset.py] All units are full, exiting.")
                break

            # Skip empty words
            if not words.strip():
                continue
            removed_units = []
            for i, word_unit_info in enumerate(units):
                unit_str = word_unit_info["unit_args"]
                output_path = f"../data/14b_{unit_str}.txt"

                if count > word_unit_info["value"]:
                    # units.remove(word_limit)
                    removed_units.append(word_unit_info)

                    print(
                        f"[run/split_dataset.py] Reached limit for {unit_str}, skipping."
                    )
                    continue
                # 이어쓰기
                with open(output_path, "a", encoding="utf-8") as out:

                    # Write words until the limit is reached
                    try:
                        out.write(words)
                    except StopIteration:
                        break
            for unit in removed_units:
                units.remove(unit)


if __name__ == "__main__":
    main()
