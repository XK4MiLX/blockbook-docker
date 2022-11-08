#!/bin/bash

stop_script() {
  echo -e "Stopping daemon (EXIT)..."
  timeout 10 ${COIN}-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" stop
  pkill -9 ${COIN}d
  exit 0
}

trap stop_script SIGINT SIGTERM

if [[ "$DAEMON" == "1" ]]; then
echo -e ""
echo -e "Daemon Luncher v1.0 $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "---------------------------------------------------------------------------"
#Enable Config file
if [[ "$CONFIG" == "1" ]]; then
  if [[ ! -f /root/.$COIN/$COIN.conf ]]; then
    mkdir -p /root/.$COIN
    echo -e "Creating config file..."
    cat <<- EOF > /root/.$COIN/$COIN.conf
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
rpcuser=$RPC_USER
rpcpassword=$RPC_PASS
EOF
  if [[ "$EXTRACONFIG" != "" ]]; then
    echo -e "$EXTRACONFIG" >> /root/.$COIN/$COIN.conf
  fi
 fi
fi

#Enable fetch params
if [[ "$FETCH_FILE" != "" ]]; then
  if [[ ! -d /root/.zcash-params ]]; then
    echo -e "Installing fetch-params..."
    bash $FETCH_FILE > /dev/null 2>&1 && sleep 2
  fi
fi


if [[ -f /usr/local/bin/${COIN}d ]]; then
  echo -e "Stopping daemon (START)..."
  timeout 10 ${COIN}-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" stop
  pkill -9 ${COIN}d
fi

if [[ ! -f /usr/local/bin/${COIN}d ]]; then
  echo -e "Downloading daemon ($COIN)..."
  cd /tmp
  mkdir backend
  
  if [[ "$DAEMON_URL" == "" ]]; then
    echo -e "Reading binary url from blockbook config..." 
    if [[ "$ALIAS" == "" ]]; then
      DAEMON_URL=$(curl -sSL https://raw.githubusercontent.com/trezor/blockbook/master/configs/coins/${COIN}.json | jq -r .backend.binary_url)
    else
      DAEMON_URL=$(curl -sSL https://raw.githubusercontent.com/trezor/blockbook/master/configs/coins/${ALIAS}.json | jq -r .backend.binary_url)
    fi
  fi
  
  echo -e "BINARY URL: $DAEMON_URL"
  wget -q --show-progress -c -t 5 $DAEMON_URL
  strip_lvl=$(tar -tvf ${DAEMON_URL##*/} | grep ${COIN}d$ | awk '{ printf "%s\n", $6 }' | awk -F\/ '{print NF-1}')
  tar --exclude="share" --exclude="lib" --exclude="include" -C backend --strip $strip_lvl -xf ${DAEMON_URL##*/}
  echo -e "Installing daemon ($COIN)..."
  install -m 0755 -o root -g root -t /usr/local/bin backend/*
  rm -rf /tmp/*
fi

cd /
sleep 5
if [[ "$CONFIG" == "0" || "$CONFIG" == "" ]]; then
  echo -e "Starting $COIN daemon (Config: Disabled)..."
  ${COIN}d -rpcuser="$RPC_USER" \
    -rpcpassword="$RPC_PASS" \
    -rpcport="$RPC_PORT" \
    -server \
    ${EXTRAFLAGS}
else
  echo -e "Starting $COIN daemon (Config: Enabled)..."
  ${COIN}d
fi
else
  echo -e "Daemon Luncher is disabled..."
  exit
fi
