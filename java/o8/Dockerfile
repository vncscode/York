FROM ubuntu:22.04

LABEL author="Drysius" maintainer="danielolxlol@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/drysius/York"
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update -y \
    && apt-get install -y wget curl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/jdk8.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u472-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u472b08.tar.gz \
    && tar -xzf /tmp/jdk8.tar.gz -C /opt/ \
    && rm /tmp/jdk8.tar.gz \
    && mv /opt/jdk8u472-b08 /opt/jdk1.8.0_472

ENV JAVA_HOME=/opt/jdk1.8.0_472
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update -y \
    && apt-get install -y lsof zip unzip openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verificar instalação
RUN java -version && javac -version

RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
