#!/usr/bin/env bash
CONFIG_FILE=${CONFIG_FILE:-$COIN}
CONFIG_DIR=${CONFIG_DIR:-$COIN}
BLOCKBOOKGIT_URL=${BLOCKBOOKGIT_URL:-https://github.com/trezor/blockbook.git}
if [[ ! -f /root/blockchaincfg.json ]]; then
  start_build=`date +%s`
  echo -e "| BLOCKBOOK BUILDER v1.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
  echo -e "-----------------------------------------------------"
  #echo -e "| Installing RocksDB [$ROCKSDB_VERSION]..."
  #cd /root && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git > /dev/null 2>&1
  #cd /root/rocksdb && CFLAGS=-fPIC CXXFLAGS="-fPIC -Wno-error=deprecated-copy -Wno-error=pessimizing-move -Wno-error=class-memaccess" make -j 4 release > /dev/null 2>&1
  #echo -e "| Installing BlockBook..."
  echo -e "| RocksDB: $ROCKSDB_VERSION, GOLANG: $GOLANG_VERSION"
  echo -e "| GITHUB URL: $BLOCKBOOKGIT_URL"
  echo -e "| BRANCH: $TAG" 
 # cd /root && git clone $BLOCKBOOKGIT_URL > /dev/null 2>&1 && \
 # cd /root/blockbook && \
 # git checkout "$TAG" > /dev/null 2>&1 && \
 # go mod download && \
 # BUILDTIME=$(date --iso-8601=seconds); \
 # GITCOMMIT=$(git describe --always --dirty); \
 # LDFLAGS="-X github.com/trezor/blockbook/common.version=${TAG} -X github.com/trezor/blockbook/common.gitcommit=${GITCOMMIT} -X github.com/trezor/blockbook/common.buildtime=${BUILDTIME}" && \
#  go build -tags rocksdb_6_16 -ldflags="-s -w ${LDFLAGS}"
#  echo -e "| Build: $BUILDTIME, Commit: $GITCOMMIT, Version: $TAG, Duration: $((($(date +%s)-$start_build)/60)) min. $((($(date +%s)-$start_build) % 60)) sec."
  if [[ -f /opt/blockbook/blockbook ]]; then
    echo -e "| Blockbook build [OK]..."
  fi
    #echo -e "| Blockbook build [FAILED]..."
    #echo -e "| Cleaning..."
   # echo -e "-----------------------------------------------------"
    #rm -rf /root/blockbook > /dev/null 2>&1
    #rm -rf /root/libzmq > /dev/null 2>&1
    #rm -rf /root/rocksdb > /dev/null 2>&1
    #rm -rf /root/go > /dev/null 2>&1
    #exit 1
  #fi
  
  if [[ ! -d /root/$CONFIG_DIR ]]; then
    echo -e "| Creating config directory..."
    mkdir -p /root/$CONFIG_DIR
  fi
  cd /opt/blockbook 
  echo -e "| Generating config files for $COIN"
  go run build/templates/generate.go $COIN > /dev/null  
  if [[ -f /opt/blockbook/build/pkg-defs/blockbook/blockchaincfg.json ]]; then
    echo -e "| Moving blockchaincfg.json"
    mv /opt/blockbook/build/pkg-defs/blockbook/blockchaincfg.json /root
  fi
  
  if [[ "$DAEMON_CONFIG" == "AUTO" ]]; then
    if [[ -f /opt/blockbook/build/pkg-defs/backend/server.conf ]]; then
      echo -e "| Moving $CONFIG_FILE.conf"
      mv /opt/blockbook/build/pkg-defs/backend/server.conf /root/$CONFIG_DIR/$CONFIG_FILE.conf
    fi
  fi
  rm -rf /opt/blockbook/build/pkg-defs
  if [[ ! -f /root/CRONE_CREATE ]]; then
    echo -e "| Added crone job for log cleaner..."
    (crontab -l -u "$USER" 2>/dev/null; echo "0 0 1-30/5 * *  /bin/bash /clean.sh > /tmp/clean_output.log 2>&1") | crontab -
    echo -e "Cron job added!" >> /root/CRONE_CREATE
  else
     echo -e "Cron job already exist..."
  fi
  echo -e "-----------------------------------------------------"
else
  echo -e "| BLOCKBOOK ALREADY INSTALLED.."
  echo -e "-----------------------------------------------------"
  sleep 5
fi
