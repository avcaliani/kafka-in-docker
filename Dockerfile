FROM eclipse-temurin:21-jre-alpine-3.24

# Kafka Version 👇
ARG KAFKA_VERSION="4.3.1"
ARG KAFKA_SCALA_VERSION="2.13"
# SHA-512 of the tarball above 👇
# Source: https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512
# ⚠️ Must be updated together with KAFKA_VERSION (and KAFKA_SCALA_VERSION).
ARG KAFKA_SHA512="c7d7b2318cb51aa0c61d3246a51c349210073c5c9b754947ef965a439f2f939e8600f204e134a75ac31faf3829c9370960ef7c6a9886c8a1dbf0339a21f4c54c"

ENV KAFKA_HOME="/opt/kafka"
ENV PATH="$PATH:${KAFKA_HOME}/bin"

# Scripts Dependencies 👇
RUN apk add --no-cache bash jq

# Installing Kafka (download, verify, extract, clean up in a single layer) 👇
RUN wget -q -O /tmp/kafka.tgz \
      "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && echo "${KAFKA_SHA512}  /tmp/kafka.tgz" | sha512sum -c - \
    && mkdir -p "${KAFKA_HOME}" \
    && tar xzf /tmp/kafka.tgz -C "${KAFKA_HOME}" --strip-components=1 \
    && rm /tmp/kafka.tgz

# Kafka Configuration 👇
WORKDIR ${KAFKA_HOME}
COPY resources/kafka/start-kafka.sh .
COPY resources/kafka/kafka-server.properties "${KAFKA_HOME}/config/"

# Custom Scripts 👇
COPY scripts/ /opt/scripts/

EXPOSE 9092 29092

CMD ["bash", "start-kafka.sh"]
