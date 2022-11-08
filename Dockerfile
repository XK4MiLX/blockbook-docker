FROM debian:10
ENV DEBIAN_FRONTEND noninteractive

#ENV TZ=Europe/Warsaw
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git wget autoconf automake jq supervisor procps curl \
    graphviz libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libunwind-dev \
    bsdmainutils build-essential g++-multilib libc6-dev libtool \
    m4 ncurses-dev pkg-config python3 python3-zmq zlib1g-dev libzmq3-dev

ENV TAG=master
ENV RPC_USER=${RPC_USER:-user}
ENV RPC_PASS=${RPC_PASS:-pass}
ENV HOME=/root
ENV DAEMON=${DAEMON:-1}
ENV CONFIG=${CONFIG:-1}
ENV GOLANG_VERSION=go1.17.1.linux-amd64
ENV ROCKSDB_VERSION=v6.22.1
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin
ENV CGO_CFLAGS="-I$HOME/rocksdb/include"
ENV CGO_LDFLAGS="-L$HOME/rocksdb -lrocksdb -lstdc++ -lm -lz -ldl -lbz2 -lsnappy -llz4"
# Install and configure go
RUN cd /opt && wget https://dl.google.com/go/$GOLANG_VERSION.tar.gz && \
    tar xf $GOLANG_VERSION.tar.gz
RUN ln -s /opt/go/bin/go /usr/bin/go
RUN mkdir -p $GOPATH
RUN echo -n "GO version: " && go version
RUN echo -n "GOPATH: " && echo $GOPATH

COPY build.sh /build.sh
COPY daemon.sh /daemon.sh
COPY blockbook.sh /blockbook.sh
COPY check-health.sh /check-health.sh
RUN chmod 755 /blockbook.sh /daemon.sh /build.sh /check-health.sh
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /root
EXPOSE $BLOCKBOOK_PORT

HEALTHCHECK --start-period=10m --interval=1m --retries=5 --timeout=20s CMD ./check-health.sh
ENTRYPOINT ["/usr/bin/supervisord"]
