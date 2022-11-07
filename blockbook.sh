#!/bin/bash

TRY=1
echo -e "Blockbook Luncher v1.0"
echo -e "----------------------------------------------------------------------------------------------------"
echo -e "Blockbook Settings: COIN=${COIN}, RPC_USER=${RPC_USER}, RPC_PASS=${RPC_PASS}, RPC_PORT=${RPC_PORT}, BLOCKBOOK_PORT=${BLOCKBOOK_PORT}"
while true; do
   echo -e "Awaiting for Blockbook build...($TRY)"
   if [[ -d /root/blockbook ]]; then
     sleep 20
     break
   fi
   sleep 150
   ((TRY=TRY+1))
done

echo -e "Updating blockchaincfg.json..."
RPC_HOST="${RPC_HOST:-localhost}"
MQ_PORT="${MQ_URL:-29000}"
CFG_FILE=/root/blockbook/build/blockchaincfg.json

echo "$(jq -r --arg key "rpc_user" --arg value "$RPC_USER" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
echo "$(jq -r --arg key "rpc_pass" --arg value "$RPC_PASS" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
echo "$(jq -r --arg key "rpc_timeout" --argjson value 50 '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
echo "$(jq -r --arg key "rpc_url" --arg value "http://$RPC_HOST:$RPC_PORT" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
echo "$(jq -r --arg key "message_queue_binding" --arg value "tcp://$RPC_HOST:$MQ_PORT" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE

cd /root/blockbook
echo -e "Starting Blockbook ($COIN)..."
exec ./blockbook -sync -blockchaincfg=/root/blockbook/build/blockchaincfg.json -debug -workers=${WORKERS:-1} -public=:${BLOCKBOOK_PORT} -logtostderr
