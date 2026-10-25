import csv
import json
from collections.abc import Iterable
from pathlib import Path


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="") as file:
        return list(csv.DictReader(file))


def write_stdout(records: Iterable[dict]) -> None:
    for record in records:
        print(json.dumps(record), flush=True)


def write_csv(path: Path, records: Iterable[dict]) -> None:
    with path.open("w", newline="") as file:
        writer: csv.DictWriter | None = None
        for record in records:
            if writer is None:
                writer = csv.DictWriter(file, fieldnames=list(record.keys()))
                writer.writeheader()
            writer.writerow(record)
            file.flush()
