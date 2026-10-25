# ⚙️ Custom Scripts

How can you use the custom scripts?

### 01 - Kafka Dev Service in Your Project

You need to configure a `kafka-dev` service in your other project, like this 👇

```yml
# docker-compose.yml
services:
    kafka-dev:
        image: avcaliani/kafka-in-docker
        container_name: kafka-dev
        ports:
            - "127.0.0.1:9092:9092" # Kafka
        healthcheck:
            test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1"]
            interval: 10s
            timeout: 10s
            retries: 10
            start_period: 30s

    # Optional: any service that needs a ready broker.
    my-app:
        image: my-app
        depends_on:
            kafka-dev:
                condition: service_healthy
```

> 💡 The healthcheck lets other services wait for a ready broker (`condition: service_healthy`) instead of sleeping or retrying.

### 02 - Execute the Script

#### DonutCoin Transactions 🍩

```bash
docker compose exec kafka-dev /opt/scripts/donu-transactions.sh
```

The script creates the topic (3 partitions) if it doesn't exist and keeps a single producer open, sending ~10 messages per second by default.
Press `CTRL + C` to stop it. If the producer fails (e.g. broker down), the script exits with the producer's error code.

Payload Example 👇

```json
// topic: DONU_TRANSACTIONS_V1
{
    "transaction_id": "82e4648eba623c53a22e3b6fbec9308f77d8a27631d74358a2176ed315330a7b",
    "timestamp": "2025-04-07T20:47:06Z",
    "from": "16",
    "to": "20",
    "amount": 7.63421,
    "currency": "DONU",
    "fee": 0.38171
}
```

The `transaction_id` is the sha256 of `from::to::amount::timestamp`, so you can rebuild it from the message fields to confirm they generated that id.

The broker and the seconds between messages can be overridden through env vars (defaults shown) 👇

```bash
docker compose exec \
    -e KAFKA_BROKER="kafka-dev:29092" \
    -e MESSAGE_INTERVAL="0.1" \
    kafka-dev /opt/scripts/donu-transactions.sh
```

### 03 - Mock Data Generator 🐍

`main.py` creates fake Simpsons data with the Python standard library only (Python 3.11+, run it inside a virtualenv).
The users and products come from the CSV files in `data/simpsons/`.

```bash
# 5 donu transactions as JSON lines in the terminal
python main.py donu-transactions --count 5

# 1000 Kiwi-e-Mart purchases in a CSV file, 10% of them wrong
python main.py kiwi-e-mart-purchases --count 1000 --error-rate 0.1 --output csv --output-path purchases.csv

# Forever (--count 0), one record every 0.5 seconds, until CTRL + C
python main.py donu-transactions --count 0 --interval 0.5
```

A wrong record has an unknown user id (`999`), a negative amount or quantity, or a blank timestamp.
