FROM amazoncorretto:21-alpine3.18

# Kafka Version 👇
ARG KAFKA_VERSION="4.0.0"
ARG KAFKA_SCALA_VERSION="2.13"

ENV KAFKA_HOME="/opt/kafka"
ENV PATH="$PATH:${KAFKA_HOME}/bin"

# Installing Kafka 👇
ADD "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz" /opt/
RUN tar xfz /opt/kafka*.tgz -C /opt && rm /opt/kafka*.tgz && mv /opt/kafka* /opt/kafka

# Kafka Configuration 👇
ADD resources/kafka/start-kafka.sh .
ADD resources/kafka/kafka-server.properties "${KAFKA_HOME}/config/"
ADD resources/kafka/meta.properties /tmp/kraft-combined-logs/

# Custom Scripts 👇
ADD scripts/ /opt/scripts/

# Scripts Dependencies 👇
RUN apk add --no-cache bash jq

CMD ["bash", "start-kafka.sh"]
