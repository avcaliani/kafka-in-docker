#!/bin/bash
# Name: donu-transactions.sh
# Description:
#   Publishes random messages to a Kafka topic "DONU_TRANSACTIONS_V1".
#   The messages are simple JSONs that represent some fake DonutCoin transactions.
#   DonutCoin (DONU) – plays on Homer’s love for donuts 🍩
#
# Usage:
#   ./donu-transactions.sh
#
# Notes:
#   To see if it's working, try reading the messages...
#   docker compose exec kafka-dev kafka-console-consumer.sh \
#       --bootstrap-server "localhost:9092" \
#       --topic "DONU_TRANSACTIONS_V1" --from-beginning
#
#   Broker and topic can be overridden with env vars, e.g.
#   KAFKA_BROKER="localhost:9092" KAFKA_TOPIC="my-topic" ./donu-transactions.sh
#
#   Linux only (reads "/proc/sys/kernel/random/uuid" for the transaction id).
#
# Dependencies:
#   bash jq

# Adding an user that doens't exist (20) on purpose.
# Check "users.csv" to see all available users.
readonly NUM_OF_USERS=21
readonly KAFKA_BROKER="${KAFKA_BROKER:-kafka-dev:29092}"
readonly KAFKA_TOPIC="${KAFKA_TOPIC:-DONU_TRANSACTIONS_V1}"

# Function: new_transaction
# Purpose:  Create a random DonutCoin transaction.
# Usage:    new_transaction
function new_transaction() {
    local from_user to_user timestamp transaction_id
    local amount_units fee_units amount fee message

    from_user=$(( RANDOM % NUM_OF_USERS ))
    to_user=$(( RANDOM % NUM_OF_USERS ))
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    transaction_id=$(< /proc/sys/kernel/random/uuid)

    # Money is handled as integers (1 unit = 0.00001 DONU) to avoid float noise.
    # Amount is in [0.00001, 10.00000] and the fee is 5% of it (rounded).
    amount_units=$(( (((RANDOM << 15) | RANDOM) % 1000000) + 1 ))
    fee_units=$(( (amount_units * 5 + 50) / 100 ))
    amount=$(printf "%d.%05d" $(( amount_units / 100000 )) $(( amount_units % 100000 )))
    fee=$(printf "%d.%05d" $(( fee_units / 100000 )) $(( fee_units % 100000 )))

    message=$(jq -nc \
        --arg transaction_id "$transaction_id" \
        --arg timestamp "$timestamp" \
        --arg from "$from_user" \
        --arg to "$to_user" \
        --argjson amount "$amount" \
        --argjson fee "$fee" \
        '{
            transaction_id: $transaction_id,
            timestamp: $timestamp,
            from: $from,
            to: $to,
            amount: $amount,
            currency: "DONU",
            fee: $fee
        }')

    # Message Pattern -> headers(key1:val1,key2:val2) msg-key:msg-value
    printf "env:dev,source:web\t%s:%s\n" "$from_user" "$message"
}

echo ""
echo "*** DonutCoin Transactions Generator **"
echo "Kafka Broker: $KAFKA_BROKER"
echo "Kafka Topic: $KAFKA_TOPIC"
echo "To stop the execution press CTRL + C ✋"
echo ""
while true; do
    message=$(new_transaction)
    echo "$message" | bash "$KAFKA_HOME/bin/kafka-console-producer.sh" \
        --bootstrap-server "$KAFKA_BROKER" \
        --topic "$KAFKA_TOPIC" \
        --property "parse.key=true" \
        --property "key.separator=:" \
        --property "parse.headers=true"
    echo "$message"
    sleep 0.25
done
exit 0
