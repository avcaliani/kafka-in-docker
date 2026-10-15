FROM eclipse-temurin:21-jre-alpine-3.24

LABEL org.opencontainers.image.source="https://github.com/avcaliani/kafka-in-docker" \
      org.opencontainers.image.title="kafka-in-docker" \
      org.opencontainers.image.description="Single-node Apache Kafka (KRaft) image for local development" \
      org.opencontainers.image.licenses="MIT"

# Kafka Version 👇
ARG KAFKA_VERSION="4.0.0"
ARG KAFKA_SCALA_VERSION="2.13"
# SHA-512 of the tarball above 👇
# Source: https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512
# ⚠️ Must be updated together with KAFKA_VERSION (and KAFKA_SCALA_VERSION).
ARG KAFKA_SHA512="00722ab0a6b954e0006994b8d589dcd8f26e1827c47f70b6e820fb45aa35945c19163b0f188caf0caf976c11f7ab005fd368c54e5851e899d2de687a804a5eb9"

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
