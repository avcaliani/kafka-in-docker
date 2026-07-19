# 🚀 Releasing

How to publish a new image version to [DockerHub](https://hub.docker.com/r/avcaliani/kafka-in-docker).

### 01 - Tag the Release

The docker image tag matches the git tag (repo version), not the `KAFKA_VERSION` build arg.

```bash
git tag "1.1.0"
git push origin "1.1.0"
```

### 02 - Build the Image

```bash
docker build -t "avcaliani/kafka-in-docker:1.1.0" -t "avcaliani/kafka-in-docker:latest" .
```

### 03 - Push to DockerHub

```bash
docker login
docker push "avcaliani/kafka-in-docker:1.1.0"
docker push "avcaliani/kafka-in-docker:latest"
```
