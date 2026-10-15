# 🚀 Releasing

How to publish a new image version to [DockerHub](https://hub.docker.com/r/avcaliani/kafka-in-docker).

### 01 - Tag the Release

The docker image tag matches the git tag (repo version), not the `KAFKA_VERSION` build arg.

```bash
git tag "1.2.0"
git push origin "1.2.0"
```

### 02 - Build and Push the Image

The image is built for `linux/amd64` and `linux/arm64`, so it works on Intel/AMD machines and Apple Silicon.  
A multi-platform image can't be loaded into the local Docker, so build and push in a single command.

```bash
docker login
docker buildx build --platform linux/amd64,linux/arm64 \
    -t "avcaliani/kafka-in-docker:1.2.0" -t "avcaliani/kafka-in-docker:latest" \
    --push .
```
