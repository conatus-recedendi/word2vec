from collections import defaultdict, Counter


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
            print(f"{i}. {word} ({freq})")
        print()


# 사용 예시
parse_analogy_log("../output/p1_exp5_20250630_0118/cbow_783M_300d_iter3.log")
