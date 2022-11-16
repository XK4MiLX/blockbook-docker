FROM debian:11
ENV DEBIAN_FRONTEND noninteractive

#ENV TZ=Europe/Warsaw
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git wget autoconf automake jq bc supervisor procps curl \
    graphviz libsnappy-dev libzstd-dev zlib1g-dev libbz2-dev liblz4-dev libunwind-dev \
    bsdmainutils build-essential g++-multilib libc6-dev pv libtool \
    m4 ncurses-dev pkg-config python3 python3-zmq zlib1g-dev libzmq3-dev

ENV TAG=${TAG:-master}
ENV RPC_USER=${RPC_USER:-user}
ENV RPC_PASS=${RPC_PASS:-pass}
ENV HOME=/root
ENV BOOTSTRAP=${BOOTSTRAP:-0}
ENV DAEMON=${DAEMON:-1}
ENV CONFIG=${CONFIG:-AUTO}
ENV GOLANG_VERSION=go1.19.2.linux-amd64
ENV ROCKSDB_VERSION=v7.7.2
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

HEALTHCHECK --start-period=10m --interval=4m --retries=5 --timeout=40s CMD ./check-health.sh
ENTRYPOINT ["/usr/bin/supervisord"]
