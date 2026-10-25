import random
from datetime import UTC, datetime
from hashlib import sha256
from uuid import uuid4

UNKNOWN_USER_ID = "999"
TIMESTAMP_FORMAT = "%Y-%m-%dT%H:%M:%SZ"
BREAKS = ["unknown_user", "negative_number", "blank_timestamp"]


def now_utc() -> str:
    return datetime.now(UTC).strftime(TIMESTAMP_FORMAT)


def new_transaction(users: list[dict[str, str]]) -> dict:
    from_user = random.choice(users)["user_id"]
    to_user = random.choice(users)["user_id"]
    timestamp = now_utc()
    amount = random.randint(1, 1_000_000) / 100_000
    transaction_id = sha256(f"{from_user}::{to_user}::{amount}::{timestamp}".encode()).hexdigest()
    return {
        "transaction_id": transaction_id,
        "timestamp": timestamp,
        "from": from_user,
        "to": to_user,
        "amount": amount,
        "currency": "DONU",
        "fee": round(amount * 0.05, 5),
    }


def new_market_purchase(users: list[dict[str, str]], products: list[dict[str, str]]) -> dict:
    product = random.choice(products)
    base_cost = float(product["product_base_cost"])
    return {
        "purchase_id": str(uuid4()),
        "user_id": random.choice(users)["user_id"],
        "product_id": product["product_id"],
        "quantity": random.randint(1, 10),
        "price": round(base_cost * random.uniform(0.95, 1.05), 2),
        "timestamp": now_utc(),
    }


def break_transaction(transaction: dict) -> dict:
    kind = random.choice(BREAKS)
    if kind == "unknown_user":
        return {**transaction, "from": UNKNOWN_USER_ID}
    if kind == "negative_number":
        return {**transaction, "amount": -transaction["amount"]}
    return {**transaction, "timestamp": ""}


def break_market_purchase(purchase: dict) -> dict:
    kind = random.choice(BREAKS)
    if kind == "unknown_user":
        return {**purchase, "user_id": UNKNOWN_USER_ID}
    if kind == "negative_number":
        return {**purchase, "quantity": -purchase["quantity"]}
    return {**purchase, "timestamp": ""}
