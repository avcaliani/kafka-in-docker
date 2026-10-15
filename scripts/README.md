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
            - 9092:9092 # Kafka
```

### 02 - Execute the Script

#### DonutCoin Transactions 🍩

```bash
docker compose exec kafka-dev /opt/scripts/donu-transactions.sh
```

The script creates the topic (3 partitions) if it doesn't exist and keeps a single producer open, sending ~4 messages per second.
Press `CTRL + C` to stop it. If the producer fails (e.g. broker down), the script exits with the producer's error code.

Payload Example 👇

```json
// topic: DONU_TRANSACTIONS_V1
{
    "transaction_id": "3f2b8c1e-6a4d-4e0b-9d7a-5c1f2e8b7a90",
    "timestamp": "2025-04-07T20:47:06Z",
    "from": "16",
    "to": "20",
    "amount": 7.63421,
    "currency": "DONU",
    "fee": 0.38171
}
```

Broker and topic can be overridden through env vars (defaults shown) 👇

```bash
docker compose exec \
    -e KAFKA_BROKER="kafka-dev:29092" \
    -e KAFKA_TOPIC="DONU_TRANSACTIONS_V1" \
    kafka-dev /opt/scripts/donu-transactions.sh
```
