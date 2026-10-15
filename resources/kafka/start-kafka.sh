#!/usr/bin/env bash
# Name: start-kafka.sh
# Description: Kafka initialization script.
#
# Usage:
#   ./start-kafka.sh
set -eu

echo ""
echo "================================"
echo " 🆙 Kafka Initialization Script"
echo "================================"
echo "Java Home..: $JAVA_HOME"
echo "Kafka Home.: $KAFKA_HOME"
echo ""

STORAGE="$KAFKA_HOME/bin/kafka-storage.sh"
CONFIG="$KAFKA_HOME/config/kafka-server.properties"
if ! bash "$STORAGE" info -c "$CONFIG" >/dev/null 2>&1; then
    echo "👉 Formatting storage..."
    bash "$STORAGE" format -t "$(bash "$STORAGE" random-uuid)" -c "$CONFIG"
fi

echo "👉 Kafka..."
exec bash "$KAFKA_HOME/bin/kafka-server-start.sh" "$CONFIG"
