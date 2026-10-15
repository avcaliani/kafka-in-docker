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
#   The topic is created once (3 partitions) if it doesn't exist, then a single
#   long-lived "kafka-console-producer.sh" reads the messages from a generator
#   loop through a pipe (~10 msg/s by default). Messages are sent synchronously, so if the
#   broker is unreachable the producer exits and the script fails with its exit code.
#
#   To see if it's working, try reading the messages...
#   docker compose exec kafka-dev kafka-console-consumer.sh \
#       --bootstrap-server "localhost:9092" \
#       --topic "DONU_TRANSACTIONS_V1" --from-beginning
#
#   Broker and the seconds between messages (default 0.1) can be overridden with
#   env vars, e.g.
#   KAFKA_BROKER="localhost:9092" MESSAGE_INTERVAL="0.5" ./donu-transactions.sh
#
#   The transaction id is the sha256 of "from::to::amount::timestamp", so it can
#   be rebuilt from the message fields to confirm they generated that id.
#
# Dependencies:
#   bash jq
#   KAFKA_HOME (kafka-topics.sh and kafka-console-producer.sh)

set -euo pipefail

# Adding an user that doens't exist (20) on purpose.
# Check "users.csv" to see all available users.
readonly NUM_OF_USERS=21
readonly KAFKA_BROKER="${KAFKA_BROKER:-kafka-dev:29092}"
readonly KAFKA_TOPIC="DONU_TRANSACTIONS_V1"
readonly MESSAGE_INTERVAL="${MESSAGE_INTERVAL:-0.1}"
readonly KAFKA_BIN="${KAFKA_HOME:?KAFKA_HOME must be set}/bin"

# Function: new_transaction
# Purpose:  Create a random DonutCoin transaction.
# Usage:    new_transaction
function new_transaction() {
    local from_user to_user timestamp transaction_id
    local amount_units fee_units amount fee message

    from_user=$(( RANDOM % NUM_OF_USERS ))
    to_user=$(( RANDOM % NUM_OF_USERS ))
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Money is handled as integers (1 unit = 0.00001 DONU) to avoid float noise.
    # Amount is in [0.00001, 10.00000] and the fee is 5% of it (rounded).
    amount_units=$(( (((RANDOM << 15) | RANDOM) % 1000000) + 1 ))
    fee_units=$(( (amount_units * 5 + 50) / 100 ))
    amount=$(printf "%d.%05d" $(( amount_units / 100000 )) $(( amount_units % 100000 )))
    fee=$(printf "%d.%05d" $(( fee_units / 100000 )) $(( fee_units % 100000 )))

    # jq prints numbers without trailing zeros (7.50000 becomes 7.5), so use that
    # form in the hash. This way the id can be rebuilt from the message fields.
    amount=$(jq -n "$amount")
    transaction_id=$(echo -n "$from_user::$to_user::$amount::$timestamp" | sha256sum | cut -d' ' -f1)

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

# Function: generate_loop
# Purpose:  Print a new transaction every MESSAGE_INTERVAL seconds, forever.
# Usage:    generate_loop | producer
function generate_loop() {
    while true; do
        new_transaction
        sleep "$MESSAGE_INTERVAL"
    done
}

# Function: create_topic
# Purpose:  Create the topic once, doesn't fail if it already exists.
# Usage:    create_topic
function create_topic() {
    bash "$KAFKA_BIN/kafka-topics.sh" \
        --bootstrap-server "$KAFKA_BROKER" \
        --create --if-not-exists \
        --topic "$KAFKA_TOPIC" \
        --partitions 3 \
        --replication-factor 1
}

# Function: produce
# Purpose:  Single long-lived producer, reads the messages from stdin.
# Usage:    generate_loop | produce
function produce() {
    bash "$KAFKA_BIN/kafka-console-producer.sh" \
        --bootstrap-server "$KAFKA_BROKER" \
        --topic "$KAFKA_TOPIC" \
        --sync \
        --producer-property "linger.ms=0" \
        --property "parse.key=true" \
        --property "key.separator=:" \
        --property "parse.headers=true"
}

function main() {
    echo ""
    echo "*** DonutCoin Transactions Generator **"
    echo "Kafka Broker: $KAFKA_BROKER"
    echo "Kafka Topic: $KAFKA_TOPIC"
    echo "To stop the execution press CTRL + C ✋"
    echo ""

    create_topic

    # CTRL + C reaches the whole pipeline (same process group), so the producer
    # flushes and exits by itself. The trap only marks it as an expected stop.
    local stopping=false
    trap 'stopping=true' INT

    # PIPESTATUS is needed because with "pipefail" a SIGPIPE in
    # the generator would hide the real exit code of the producer.
    local statuses
    set +e
    generate_loop | tee /dev/stderr | produce
    statuses=("${PIPESTATUS[@]}")
    set -e

    if [[ "$stopping" == true ]]; then
        echo ""
        echo "Stopped."
        exit 0
    fi
    if [[ "${statuses[2]}" -ne 0 ]]; then
        echo "ERROR: kafka-console-producer.sh failed (exit code ${statuses[2]})." >&2
        exit "${statuses[2]}"
    fi
    if [[ "${statuses[0]}" -ne 0 && "${statuses[0]}" -ne 141 ]]; then
        echo "ERROR: generator failed (exit code ${statuses[0]})." >&2
        exit "${statuses[0]}"
    fi
    exit 0
}

# Only runs when executed, so the functions can be sourced for testing.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
