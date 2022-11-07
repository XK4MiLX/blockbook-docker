#!/bin/bash

CURRENT_NODE_HEIGHT=$($COIN-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" -getinfo 2>/dev/null | jq .blocks)
if [[ "$CURRENT_NODE_HEIGHT" == "" ]]; then
  CURRENT_NODE_HEIGHT=$($COIN-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" getinfo 2>/dev/null | jq .blocks)
fi

if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo "Daemon not working correct..."
  exit 1
else
  curl -sSL  http://localhost:$BLOCKBOOK_PORT/api
  exit
fi

