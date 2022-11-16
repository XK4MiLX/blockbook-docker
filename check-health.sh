#!/bin/bash

if [[ "$CONFIG_DIR" == "" ]]; then
  CONFIG_DIR=$COIN
fi

if [[ "$CLI_NAME" == "" ]]; then
  if [[ -f /root/daemon_config.json ]]; then
    CLI_NAME=$(jq -r .cli_name /root/daemon_config.json)
  fi
fi

if [[ "$CLI_NAME" == "" ]]; then
  echo -e "HEALCHECK [DISABLED]"
  exit 1
fi

if [[ -f /root/.${CONFIG_DIR}/${COIN}.conf ]]; then
  CURRENT_NODE_HEIGHT=$(${CLI_NAME} -conf="/root/${CONFIG_DIR}/${COIN}.conf" -getinfo 2>/dev/null | jq .blocks)
  if [[ "$CURRENT_NODE_HEIGHT" == "" ]]; then
    CURRENT_NODE_HEIGHT=$(${CLI_NAME} -conf="/root/${CONFIG_DIR}/${COIN}.conf" getinfo 2>/dev/null | jq .blocks)
  fi
else
  CURRENT_NODE_HEIGHT=$(${CLI_NAME} -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" -getinfo 2>/dev/null | jq .blocks)
  if [[ "$CURRENT_NODE_HEIGHT" == "" ]]; then
    CURRENT_NODE_HEIGHT=$(${CLI_NAME} -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" getinfo 2>/dev/null | jq .blocks)
  fi
fi


if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo -e "Daemon = [FAILED]"
  exit 1
else
  blockbookapi=$(curl -sSL  http://localhost:$BLOCKBOOK_PORT/api 2>/dev/null | jq .)
  bloks=$(jq -r .backend.blocks <<< "$blockbookapi")
  headers=$(jq -r .backend.headers <<< "$blockbookapi")
  blockbook=$(jq -r .blockbook.bestHeight <<< "$blockbookapi")
  if [[ $bloks != "" && $headers != "" ]]; then
    progress1=$(awk 'BEGIN {total=ARGV[1] / ARGV[2]; printf("%.2f", total*100)}' $bloks $headers)
    progress2=$(awk 'BEGIN {total=ARGV[1] / ARGV[2]; printf("%.2f", total*100)}' $blockbook $headers)
    echo -e "Blockbook = [OK], Daemon = [OK], Daemon Sync: $progress1%, Blockbook Sync: $progress2%"
  else
    echo -e "Blockbook = [FAILED], Daemon = [OK]"
    exit 1
  fi
  exit
fi
