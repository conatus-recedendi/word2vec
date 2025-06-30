import sys
from collections import defaultdict, Counter

vocab = set()
vocab_cnt = 0


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


def fill_vocab(file_path):
    global vocab_cnt
    global vocab
    progress = 0
    with open(file_path, "r", encoding="utf-8") as f:
        read_words_from_stream(f)
        while True:
            chunk = f.read(4096)
            if not chunk:
                break

            # Show progress
            progress += len(chunk)
            sys.stdout.write(
                f"\rProcessing {file_path}: {progress / 1024 / 1024:.2f} MB processed"
            )
            sys.stdout.flush()
            words = chunk.split()

            for word in words:
                if word.strip():
                    vocab.add(word)
                    vocab_cnt += 1


def parse_analogy_log(file_path):
    task_errors = defaultdict(list)
    current_task = None

    with open(file_path, "r") as f:
        lines = f.readlines()

        for i in range(len(lines)):
            line = lines[i].strip()

            # Task section starts
            if (
                line.startswith("gram")
                or line.startswith("capital-common-countries")
                or line.startswith("capital-world")
                or line.startswith("currency")
                or line.startswith("city-in-state")
                or line.startswith("family")
            ):
                current_task = line[1:].strip()
                continue

            if "[Wrong]" in line:
                parts = line.split("Predicted: ")
                if len(parts) >= 2:
                    predicted_part = parts[1].strip()
                    predicted_word = predicted_part.split()[0]  # Only the word
                    if current_task:
                        task_errors[current_task].append(predicted_word)

    # Display
    for task, preds in task_errors.items():
        print(f"Task: {task}")
        counter = Counter(preds)
        for i, (word, freq) in enumerate(counter.most_common(10), 1):
            print(
                f"{i}. {word} ({freq}) / {vocab.count(word) if word in vocab else 0} / {vocab.count(word) / vocab_cnt * 100:.2f}%)"
            )
        print()


fill_vocab("../data/14b_783M.txt")  # Fill the vocab set with words from the dataset
# 사용 예시
parse_analogy_log("../output/p1_exp5_20250630_0118/cbow_783M_300d_iter3.log")
