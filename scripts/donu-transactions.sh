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
# Dependencies:
#   bash jq

# Adding an user that doens't exist (20) on purpose.
# Check "users.csv" to see all available users.
readonly NUM_OF_USERS=21 
readonly KAFKA_BROKER="kafka-dev:29092"
readonly KAFKA_TOPIC="DONU_TRANSACTIONS_V1"

# Function: new_transaction
# Purpose:  Create a random DonutCoin transaction.
# Usage:    new_transaction
function new_transaction() {
    from_user=$(( RANDOM % NUM_OF_USERS ))
    to_user=$(( RANDOM % NUM_OF_USERS ))
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    amount=$(awk 'BEGIN {srand(); printf "%.5f\n", rand() * 10}')
    fee=$(awk "BEGIN {printf \"%.5f\", $amount * 0.05}")
    transaction_id=$(echo -n "$from_user::$to_user::$amount::$timestamp" | sha256sum | awk '{print $1}')
    message=$(echo "{
        \"transaction_id\": \"$transaction_id\",
        \"timestamp\": \"$timestamp\",
        \"from\": \"$from_user\",
        \"to\": \"$to_user\",
        \"amount\": $amount,
        \"currency\": \"DONU\",
        \"fee\": $fee
    }" | jq -c .)
    
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