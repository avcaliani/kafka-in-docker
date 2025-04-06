#!/bin/sh
# @script       kafka.sh
# @author       @avcaliani
#
# @description
# Zookeeper and Kafka initialization script.
#
# @usage
# ./init.sh

echo "========================="
echo "🛫 Initialization Script"
echo "========================="
echo "Java Home..: $JAVA_HOME"
echo "Kafka Home.: $KAFKA_HOME"
echo ""

# The zookeeper will be started in backgorung.
echo "🟢 Initializing Zookeeper..."
bash "$KAFKA_HOME/bin/zookeeper-server-start.sh" "$KAFKA_HOME/config/zookeeper.properties" &

sleep 3
echo "🟢 Initializing Kafka..."
bash "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/kafka.properties"

exit 0
