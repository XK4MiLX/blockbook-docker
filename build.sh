#!/bin/bash

if [[ ! -d /root/blockbook ]]; then
  echo -e "Installing RocksDB..."
  cd /root && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git
  cd /root/rocksdb && CFLAGS=-fPIC CXXFLAGS=-fPIC make -j 4 release
  # Install ZeroMQ
  echo -e "Installing ZeroMQ..."
  cd /root && git clone https://github.com/zeromq/libzmq && \
    cd libzmq && \
    git checkout v4.2.1 && \
    ./autogen.sh && \
    ./configure && \
    make -j 4 && \
    make install
  echo -e "Installing BlockBook..."
  cd /root && git clone https://github.com/trezor/blockbook.git && \
  cd /root/blockbook && \
  go mod download && \
  BUILDTIME=$(date --iso-8601=seconds); \
  GITCOMMIT=$(git describe --always --dirty); \
  LDFLAGS="-X github.com/trezor/blockbook/common.version=${TAG} -X github.com/trezor/blockbook/common.gitcommit=${GITCOMMIT} -X github.com/trezor/blockbook/common.buildtime=${BUILDTIME}" && \
  go build -tags rocksdb_6_16 -ldflags="-s -w ${LDFLAGS}"
  echo -e "Build: $BUILDTIME, Commit: $GITCOMMIT, Version: $TAG"
  echo -e "Creating blockchaincfg.sh for $COIN..."
  cd /root/blockbook
  if [[ "$ALIAS" == "" ]]; then
    ./contrib/scripts/build-blockchaincfg.sh $COIN
  else
    ./contrib/scripts/build-blockchaincfg.sh $ALIAS
  fi
else
  echo -e "Blockbook already installed.."
  sleep 5
fi

