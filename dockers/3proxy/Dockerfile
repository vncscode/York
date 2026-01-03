FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Download and compile 3proxy  
WORKDIR /tmp
RUN wget https://github.com/z3APA3A/3proxy/archive/refs/tags/0.9.4.tar.gz \
    && tar -xzvf 0.9.4.tar.gz \
    && cd 3proxy-0.9.4 \
    && make -f Makefile.Linux \
    && cp src/3proxy /usr/bin/ \
    && cd .. \
    && rm -rf 3proxy-0.9.4 0.9.4.tar.gz

RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]