#!/usr/bin/env bash
CONFIG_FILE=${CONFIG_FILE:-$COIN}
CONFIG_DIR=${CONFIG_DIR:-$COIN}
BLOCKBOOKGIT_URL=${BLOCKBOOKGIT_URL:-https://github.com/trezor/blockbook.git}
echo -e "| BLOCKBOOK LUNCHER v1.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
echo -e "-----------------------------------------------------"
if [[ ! -f /root/blockchaincfg.json ]]; then
  echo -e "| RocksDB: $ROCKSDB_VERSION, GOLANG: $GOLANG_VERSION"
  echo -e "| GITHUB URL: $BLOCKBOOKGIT_URL"
  echo -e "| BRANCH: $TAG" 
  echo -e "| PATH: $HOME/blockbook" 
  if [[ -f $HOME/blockbook/blockbook ]]; then
    echo -e "| Blockbook build [OK]..."
  fi
  if [[ ! -d /root/$CONFIG_DIR ]]; then
    echo -e "| Creating config directory..."
    mkdir -p /root/$CONFIG_DIR
  fi
  cd $HOME/blockbook 
  echo -e "| Generating config files for $COIN"
  go run build/templates/generate.go $COIN > /dev/null  
  if [[ -f $HOME/blockbook/build/pkg-defs/blockbook/blockchaincfg.json ]]; then
    echo -e "| Moving blockchaincfg.json"
    mv $HOME/blockbook/build/pkg-defs/blockbook/blockchaincfg.json /root
  fi
  if [[ "$DAEMON_CONFIG" == "AUTO" ]]; then
    if [[ -f $HOME/blockbook/build/pkg-defs/backend/server.conf ]]; then
      echo -e "| Moving $CONFIG_FILE.conf"
      mv $HOME/blockbook/build/pkg-defs/backend/server.conf /root/$CONFIG_DIR/$CONFIG_FILE.conf
    fi
  fi
  rm -rf $HOME/blockbook/build/pkg-defs
  echo -e "-----------------------------------------------------"
else
  echo -e "| BLOCKBOOK ALREADY SETUP..."
  echo -e "-----------------------------------------------------"
  sleep 5
fi
echo -e "| CRON JOB CHECKING..."
[ -f /var/spool/cron/crontabs/root ] && crontab_check=$(cat /var/spool/cron/crontabs/root| grep -o clean | wc -l) || crontab_check=0
if [[ "$crontab_check" == "0" ]]; then
  echo -e "| ADDED CRONE JOB FOR LOG CLEANER..."
  echo -e "-----------------------------------------------------"
  (crontab -l -u root 2>/dev/null; echo "0 0 1-30/5 * *  /bin/bash /clean.sh > /tmp/clean_output.log 2>&1") | crontab -
else
  echo -e "| CRONE JOB ALREADY EXIST..."
  echo -e "-----------------------------------------------------"
fi
