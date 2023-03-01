#!/bin/bash

CONFIG_DIR=${CONFIG_DIR:-$COIN}

function extract_daemon() {
  if [[ ! -d /tmp/backend ]]; then
    echo -e "| Creating directory..."
    mkdir -p /tmp/backend
  fi
  echo -e "| Unpacking daemon bin archive file..."
  strip_lvl=$(bsdtar -tvf ${DAEMON_URL##*/} | grep ${BINARY_NAME}$ | awk '{ printf "%s\n", $9 }' | awk -F\/ '{print NF-1}')
  bsdtar --exclude="share" --exclude="lib" --exclude="include" -C backend --strip $strip_lvl -xf ${DAEMON_URL##*/} > /dev/null 2>&1 || return 1
  return 0
}


if [[ "$1" == "db_fix" ]]; then
  echo -e "| BLOCKBOOK DB FIXER v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
  echo -e "--------------------------------------------------"
  echo -e "| Stopping blockbook service..."
  supervisorctl stop blockbook > /dev/null 2>&1
  echo -e "| Repair the database..."
  ./opt/blockbook/blockbook -repair -datadir=/root/blockbook-db
  echo -e "| Starting blockbook service..."
  supervisorctl start blockbook > /dev/null 2>&1
  echo -e "--------------------------------------------------"
  exit
fi

if [[ "$1" == "db_clean" ]]; then
  echo -e "| BLOCKBOOK DB CLEANER v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
  echo -e "--------------------------------------------------"
  echo -e "| Stopping blockbook service..."
  supervisorctl stop blockbook > /dev/null 2>&1
  echo -e "| Removing blockbook-db..."
  rm -rf /blockbook-db/*
  echo -e "| Starting blockbook service..."
  supervisorctl start blockbook > /dev/null 2>&1
  echo -e "--------------------------------------------------"
  exit
fi

if [[ "$1" == "update_daemon" ]]; then
  echo -e "| DAEMON UPDATE v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
  echo -e "--------------------------------------------------"
  DAEMON_URL=$2
  if [[ "$DAEMON_URL" == "" ]]; then
    echo -e "| Missing binary archive url..."
    echo -e "--------------------------------------------------"
    exit
  fi
  echo -e "| Stopping daemon service..."
  supervisorctl stop daemon > /dev/null 2>&1
  if [[ "$BINARY_NAME" == "" ]]; then
    BINARY_NAME=$(jq -r .binary_name /root/daemon_config.json)
  fi
  echo -e "| Removing daemon binary..."
  rm -rf /usr/local/bin/$BINARY_NAME
  echo -e "| BINARY URL: $DAEMON_URL"
  cd /tmp
  wget -q --show-progress -c -t 5 $DAEMON_URL
  extract_daemon
  echo -e "| Installing daemon..."
  install -m 0755 -o root -g root -t /usr/local/bin backend/*
  rm -rf /tmp/*
  echo -e "| Starting daemon service..."
  supervisorctl start daemon > /dev/null 2>&1
  echo -e "--------------------------------------------------"
  exit
fi

if [[ "$1" == "backend_clean" ]]; then
  echo -e "| BACKEND CLEANER v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
  echo -e "--------------------------------------------------"
  echo -e "| Stopping daemon service..."
  supervisorctl stop daemon > /dev/null 2>&1
  echo -e "| Cleaning backend datadir..."
  rm -rf /root/$CONFIG_DIR/backend/*
  echo -e "| Starting daemon service..."
  supervisorctl start daemon > /dev/null 2>&1
  echo -e "--------------------------------------------------"
  exit
fi

CLEAN=0
echo -e "| LOG CLEANER v2.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
echo -e "--------------------------------------------------"
 LOG_SIZE_LIMIT=${LOG_SIZE_LIMIT:-20}
 LOG_LIST=($(find /root -type f \( -name "$COIN*.log" -o -name "debug.log" -o -name "blockbook.log*" -o -name "*.log" \)))
 LENGTH=${#LOG_LIST[@]}
 for (( j=0; j<${LENGTH}; j++ ));
 do
  LOG_PATH="${LOG_LIST[$j]}"
  SIZE=$(ls -l --b=M  $LOG_PATH | cut -d " " -f5)
  #echo -e "| File: ${LOG_PATH} SIZE: ${SIZE}"
  if [[ $(egrep -o '[0-9]+' <<< $SIZE) -gt $LOG_SIZE_LIMIT ]]; then
    echo -e "| FOUND: ${LOG_PATH} SIZE: ${SIZE}"
    LOG_FILE=${LOG_PATH##*/}
    echo -e "| File ${LOG_FILE} reached ${LOG_SIZE_LIMIT}M limit, file was cleaned!"
    if [[ -f $LOG_PATH ]]; then
      echo "" > $LOG_PATH > /dev/null 2>&1
    fi
    CLEAN=1
  fi
 done
 if [[ "$CLEAN" == "0" ]]; then
   echo -e "| All logs belown ${LOG_SIZE_LIMIT}M limit..."
 fi
 echo -e "--------------------------------------------------"
