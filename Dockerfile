FROM amazoncorretto:11-alpine3.18

ARG KAFKA_VERSION="3.7.0"
ARG KAFKA_SCALA_VERSION="2.13"

ENV KAFKA_HOME="/opt/kafka"
ENV PATH="$PATH:${KAFKA_HOME}/bin"

RUN apk add --no-cache bash
ADD "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz" /opt/
RUN tar xfz /opt/kafka*.tgz -C /opt && rm /opt/kafka*.tgz && mv /opt/kafka* /opt/kafka

ADD resources/init.sh .
ADD resources/kafka.properties "${KAFKA_HOME}/config/"

CMD bash init.sh
