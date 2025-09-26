FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gdal-bin \
    postgresql-client \
    bash \
    curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work