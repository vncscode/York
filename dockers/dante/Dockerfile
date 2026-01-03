FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    dante-server \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]