import random
import time
from collections.abc import Callable, Iterator
from pathlib import Path

from helpers.cli import Options, parse_args
from helpers.fs import read_csv, write_csv, write_stdout
from helpers.simpsons import (
    break_market_purchase,
    break_transaction,
    new_market_purchase,
    new_transaction,
)

DATA_DIR = Path(__file__).parent / "data" / "simpsons"


def build_record_maker(dataset: str, error_rate: float) -> Callable[[], dict]:
    users = read_csv(DATA_DIR / "characters.csv")
    products = read_csv(DATA_DIR / "kiwi-e-mart_products.csv")

    def make_donu_transaction() -> dict:
        record = new_transaction(users)
        if random.random() < error_rate:
            return break_transaction(record)
        return record

    def make_kiwi_purchase() -> dict:
        record = new_market_purchase(users, products)
        if random.random() < error_rate:
            return break_market_purchase(record)
        return record

    if dataset == "donu-transactions":
        return make_donu_transaction
    return make_kiwi_purchase


def generate_records(options: Options, make_record: Callable[[], dict]) -> Iterator[dict]:
    created = 0
    while options.count == 0 or created < options.count:
        yield make_record()
        created += 1
        time.sleep(options.interval)


def main() -> None:
    options = parse_args()
    make_record = build_record_maker(options.dataset, options.error_rate)
    records = generate_records(options, make_record)

    if options.output == "csv":
        write_csv(options.output_path, records)
        return
    write_stdout(records)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
