#!/usr/bin/env bash

if [[ ! -d /root/blockbook ]]; then
  echo -e "Installing RocksDB..."
  cd /root && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git > /dev/null 2>&1 
  cd /root/rocksdb && CFLAGS=-fPIC CXXFLAGS=-fPIC make -j 4 release > /dev/null 2>&1 
  # Install ZeroMQ
  #echo -e "Installing ZeroMQ..."
  #cd /root && git clone https://github.com/zeromq/libzmq && \
  #  cd libzmq && \
  # git checkout v4.2.1 && \
  #  ./autogen.sh && \
  #  ./configure && \
  #  make -j 4 && \
  #  make install
  echo -e "Installing BlockBook..."
  
  if [[ "$BLOCKBOOKGIT_URL" == "" ]]; then
    BLOCKBOOKGIT_URL=https://github.com/trezor/blockbook.git
  fi
  
  cd /root && git clone $BLOCKBOOKGIT_URL > /dev/null 2>&1 && \
  cd /root/blockbook && \
  go mod download > /dev/null 2>&1  && \
  BUILDTIME=$(date --iso-8601=seconds); \
  GITCOMMIT=$(git describe --always --dirty); \
  LDFLAGS="-X github.com/trezor/blockbook/common.version=${TAG} -X github.com/trezor/blockbook/common.gitcommit=${GITCOMMIT} -X github.com/trezor/blockbook/common.buildtime=${BUILDTIME}" && \
  go build -tags rocksdb_6_16 -ldflags="-s -w ${LDFLAGS}" > /dev/null 2>&1 
  echo -e "Build: $BUILDTIME, Commit: $GITCOMMIT, Version: $TAG"
  if [[ -f /root/blockbook/blockbook ]]; then
    echo -e "Blockbook build [OK]..."
  else
    echo -e "Blockbook build [FAILED]..."
    echo -e "Cleaning..."
    rm -rf /root/blockbook > /dev/null 2>&1 
    rm -rf /root/libzmq > /dev/null 2>&1 
    rm -rf /root/rocksdb > /dev/null 2>&1 
    exit 1
  fi
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

