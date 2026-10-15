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

echo "👉 Kafka..."
exec bash "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/kafka-server.properties"
