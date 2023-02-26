FROM debian:11
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git wget autoconf automake jq bc supervisor procps curl \
    graphviz libsnappy-dev libzstd-dev zlib1g-dev libbz2-dev liblz4-dev libunwind-dev \
    bsdmainutils build-essential g++-multilib libc6-dev pv libarchive-tools cron unzip libtool \
    m4 ncurses-dev pkg-config python3 python3-zmq zlib1g-dev libzmq3-dev

ENV TAG=${TAG:-master}
ENV RPC_USER=${RPC_USER:-user}
ENV RPC_PASS=${RPC_PASS:-pass}
ENV HOME=/opt
ENV BOOTSTRAP=${BOOTSTRAP:-0}
ENV DAEMON=${DAEMON:-1}
ENV CONFIG=${CONFIG:-AUTO}
ENV GOLANG_VERSION=${GOLANG_VERSION:-go1.19.2}
ENV ROCKSDB_VERSION=${ROCKSDB_VERSION:-v7.7.2}
ENV DAEMON_CONFIG=${DAEMON_CONFIG:-AUTO}
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin
ENV CGO_CFLAGS="-I$HOME/rocksdb/include"
ENV CGO_LDFLAGS="-L$HOME/rocksdb -lrocksdb -lstdc++ -lm -lz -ldl -lbz2 -lsnappy -llz4 -lzstd"
# Install GO
RUN echo -e "Installing GOLANG [$GOLANG_VERSION]..." && \
    cd /opt && wget https://dl.google.com/go/$GOLANG_VERSION.linux-amd64.tar.gz && \
    tar xf $GOLANG_VERSION.linux-amd64.tar.gz
RUN ln -s /opt/go/bin/go /usr/bin/go
RUN mkdir -p $GOPATH
RUN echo -n "GO version: " && go version
RUN echo -n "GOPATH: " && echo $GOPATH
# Install RocksDB
RUN echo -e "Installing RocksDB [$ROCKSDB_VERSION]..." && \
cd $HOME && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git && \
cd $HOME/rocksdb && CFLAGS=-fPIC CXXFLAGS="-fPIC -Wno-error=deprecated-copy -Wno-error=pessimizing-move -Wno-error=class-memaccess" make -j 4 release

COPY build.sh /build.sh
COPY daemon.sh /daemon.sh
COPY blockbook.sh /blockbook.sh
COPY check-health.sh /check-health.sh
COPY consensus.sh /consensus.sh
COPY clean.sh /clean.sh

RUN chmod 755 /blockbook.sh /daemon.sh /build.sh /check-health.sh /consensus.sh /clean.sh
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /root

EXPOSE $BLOCKBOOK_PORT

HEALTHCHECK --start-period=10m --interval=4m --retries=5 --timeout=40s CMD ./check-health.sh
ENTRYPOINT ["/usr/bin/supervisord"]
