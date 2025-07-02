#!/bin/sh
# Name: start-kafka.sh
# Description: Kafka initialization script.
#
# Usage:
#   ./start-kafka.sh
echo ""
echo "================================"
echo " 🆙 Kafka Initialization Script"
echo "================================"
echo "Java Home..: $JAVA_HOME"
echo "Kafka Home.: $KAFKA_HOME"
echo ""

echo "👉 Kafka..."
bash "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/kafka-server.properties"

exit 0
