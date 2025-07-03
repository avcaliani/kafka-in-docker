<img src="https://apache.org/logos/res/kafka/kafka_highres.png" width="128px" align="right"/>

# 📟 Kafka in Docker

![License](https://img.shields.io/github/license/avcaliani/kafka-in-docker?logo=apache&color=lightseagreen)

My goal with this repository is to have a Kafka template that I can setup locally
and use it in other projects as well, so I don't have to copy/paste not maintaing
this code/configs in every repo I need a local kafka instance.

I hope this can be useful to you too.  
I really tried to create things in a simpler and very well documented way.  
Plus, I've already left a simple script that will propagate some data for you,
so you can start doing some test faster.

Here is the **project structure** 👇

```bash
.
├── Dockerfile               # 🐋 Dockerfile with Kafka setup.
├── docker-compose.yml      # 🧩 Docker compose configuring the service.
├── resources/
│   ├── kafka/
│   │   ├── start-kafka.sh  # 🆙 Initialization script for Kafka.
│   │   └── *.properties    # 📝 Kafka properties with custom configs.
│   └── kafka-ui/
│       └── *               # 📝 Kafka UI config.
└── scripts/
    └── *.sh                # ⚙️ Some scripts to propagate some random data.
```

> 💡 More details about the **scripts** [here](./scripts/README.md).

## Quick Start

```bash
# 👇 Creates "kafka-dev" image locally
docker compose build

# Starts...
#  - The Kafka Cluster
#  - The Kafka UI at 👉 http://localhost:8080/
docker compose up -d

# 👇 Creates "kafka-dev" image locally
docker compose logs kafka-dev # Show container logs.
```

> If `docker compose` doesn't work for you, try `docker compose`.  
> If it still doesn't work, check if you have docker compose installed.

### Playground

Here are some terminal commands you can try to explore your own Kafka 😎

```bash
# Creating a topic 👇
docker compose exec kafka-dev kafka-topics.sh \
    --create \
    --bootstrap-server "localhost:9092" \
    --replication-factor "1" \
    --partitions "1" \
    --topic "MY_TOPIC"

# Checking the available topics 👇
docker compose exec kafka-dev kafka-topics.sh --list --bootstrap-server "localhost:9092"

# Producing messages 👇
docker compose exec kafka-dev kafka-console-producer.sh \
    --bootstrap-server "localhost:9092" \
    --topic "MY_TOPIC"

# Consuming messages 👇
docker compose exec kafka-dev kafka-console-consumer.sh \
    --bootstrap-server "localhost:9092" \
    --topic "MY_TOPIC" --from-beginning

# Checking the consumer groups 👇
docker compose exec kafka-dev kafka-consumer-groups.sh \
    --all-groups \
    --describe \
    --bootstrap-server "localhost:9092"
```

### Useful Links

- [Apache Kafka](https://kafka.apache.org/downloads)
- [Kafka Tool - UI Tool 4 Kafka](https://www.kafkatool.com/download.html)
- [Medium: Learning in Practice](https://medium.com/trainingcenter/apache-kafka-codifica%C3%A7%C3%A3o-na-pratica-9c6a4142a08f)
