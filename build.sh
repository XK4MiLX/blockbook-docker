#!/usr/bin/env bash
CONFIG_FILE=${CONFIG_FILE:-$COIN}
CONFIG_DIR=${CONFIG_DIR:-$COIN}
BLOCKBOOKGIT_URL=${BLOCKBOOKGIT_URL:-https://github.com/trezor/blockbook.git}
VERSION=$(curl -ssL https://raw.githubusercontent.com/$GIT_USER/$REPO/$TAG/configs/environ.json | jq -r .version)

function blockbook_install() {
  if [[ -d $HOME/blockbook ]]; then
   return
  fi
  echo -e "| Installing Blockbook [$VERSION]..."
  echo -e "| RocksDB: $ROCKSDB_VERSION, GOLANG: $GOLANG_VERSION"
  echo -e "| GITHUB URL: $BLOCKBOOKGIT_URL"
  re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(.git)*$"
  if [[ $BLOCKBOOKGIT_URL =~ $re ]]; then
   GIT_USER=${BASH_REMATCH[4]}
   REPO=$(cut -d "." -f 1 <<< ${BASH_REMATCH[5]})
  fi
  echo -e "| BRANCH: $TAG, VERSION: $VERSION"
  echo -e "| PATH: $HOME/blockbook"
  x=1
  while [ $x -le 3 ]
  do
    #####  
    cd $HOME && git clone $BLOCKBOOKGIT_URL
    cd $HOME/blockbook 
    git checkout "$TAG" 
    go mod download 
    BUILDTIME=$(date --iso-8601=seconds)
    GITCOMMIT=$(git describe --always --dirty)
    LDFLAGS="-X github.com/trezor/blockbook/common.version=${VERSION}-${TAG} -X github.com/trezor/blockbook/common.gitcommit=${GITCOMMIT} -X github.com/trezor/blockbook/common.buildtime=${BUILDTIME}"
    go build -tags rocksdb_6_16 -ldflags="-s -w ${LDFLAGS}"
    #####
    if [[ -f $HOME/blockbook/blockbook ]]; then
      echo -e "| Blockbook build [OK]..."
      break
    else
      echo -e "| Blockbook build [FAILED]..."
      rm -rf $HOME/blockbook
    fi 
    x=$(( $x + 1 ))
  done
}
echo -e "| BLOCKBOOK LUNCHER v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
echo -e "-----------------------------------------------------"
blockbook_install
if [[ ! -f /root/blockchaincfg.json ]]; then
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
