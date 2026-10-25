from argparse import ArgumentParser
from dataclasses import dataclass
from pathlib import Path

DATASETS = ["donu-transactions", "kiwi-e-mart-purchases"]
OUTPUTS = ["stdout", "csv"]


@dataclass(frozen=True)
class Options:
    dataset: str
    count: int
    output: str
    output_path: Path
    error_rate: float
    interval: float


def build_parser() -> ArgumentParser:
    parser = ArgumentParser(description="Generates mock data (Simpsons style).")
    parser.add_argument("dataset", choices=DATASETS, help="which data to generate")
    parser.add_argument("--count", type=int, default=10, help="how many records, 0 means forever (default: 10)")
    parser.add_argument("--output", choices=OUTPUTS, default="stdout", help="where to write (default: stdout)")
    parser.add_argument("--output-path", type=Path, help="CSV file path (default: <dataset>.csv)")
    parser.add_argument("--error-rate", type=float, default=0.0, help="share of wrong records, from 0 to 1 (default: 0)")
    parser.add_argument("--interval", type=float, default=0.0, help="seconds between records (default: 0)")
    return parser


def parse_args(argv: list[str] | None = None) -> Options:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.count < 0:
        parser.error("--count must be 0 or more")
    if not 0 <= args.error_rate <= 1:
        parser.error("--error-rate must be between 0 and 1")
    if args.interval < 0:
        parser.error("--interval must be 0 or more")

    return Options(
        dataset=args.dataset,
        count=args.count,
        output=args.output,
        output_path=args.output_path or Path(f"{args.dataset}.csv"),
        error_rate=args.error_rate,
        interval=args.interval,
    )
