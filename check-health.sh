#!/bin/bash
CURRENT_NODE_HEIGHT=$($COIN-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" -getinfo 2>/dev/null | jq .blocks)
if [[ "$CURRENT_NODE_HEIGHT" == "" ]]; then
  CURRENT_NODE_HEIGHT=$($COIN-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" getinfo 2>/dev/null | jq .blocks)
fi

if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo -e "Daemon = [FAILED]"
  exit 1
else
  bloks=$(curl -sSL  http://localhost:$BLOCKBOOK_PORT/api 2>/dev/null | jq -r .backend.blocks)
  headers=$(curl -sSL  http://localhost:$BLOCKBOOK_PORT/api 2>/dev/null | jq -r .backend.headers)
  if [[ $bloks != "" && $headers != "" ]]; then
    diff=$(echo $[($headers-$bloks)])
    progress=$(awk 'BEGIN {total=ARGV[1] / ARGV[2]; printf("%.2f", total*100)}' $diff $headers)
    echo -e "Blockbook = [OK], Daemon = [OK], Sync progress: $progress%"
  else
    echo -e "Blockbook = [FAILED], Daemon = [OK]"
    exit 1
  fi
  exit
fi

