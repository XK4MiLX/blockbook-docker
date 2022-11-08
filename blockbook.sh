#!/usr/bin/env bash
TRY=1
echo -e ""
echo -e "Blockbook Luncher v1.0 $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "---------------------------------------------------------------------------"
echo -e "Blockbook Settings: COIN=$COIN, RPC_USER=$RPC_USER, RPC_PASS=$RPC_PASS, RPC_PORT=$RPC_PORT, BLOCKBOOK_PORT=$BLOCKBOOK_PORT"
while true; do
   echo -e "Awaiting for Blockbook build...($TRY)"
   if [[ -d /root/blockbook ]]; then
     sleep 20
     break
   fi
   sleep 150
   ((TRY=TRY+1))
done

CFG_FILE=/root/blockbook/build/blockchaincfg.json
if [[ ! -f /root/config_created ]]; then
  echo -e "Updating blockchaincfg.json..."
  RPC_HOST="${RPC_HOST:-localhost}"
  MQ_PORT="${MQ_URL:-29000}"
  echo "$(jq -r --arg key "rpc_user" --arg value "$RPC_USER" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
  echo "$(jq -r --arg key "rpc_pass" --arg value "$RPC_PASS" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
  echo "$(jq -r --arg key "rpc_timeout" --argjson value 50 '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
  echo "$(jq -r --arg key "rpc_url" --arg value "http://$RPC_HOST:$RPC_PORT" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
  echo "$(jq -r --arg key "message_queue_binding" --arg value "tcp://$RPC_HOST:$MQ_PORT" '.[$key]=$value' $CFG_FILE)" > $CFG_FILE
  echo "Disabled updating blockchaincfg.json..." > /root/config_created
else
  echo -e "Blockchaincfg.json [LOCKED]..."
fi

cd /root/blockbook
echo -e "Starting Blockbook ($COIN)..."
exec ./blockbook -sync -blockchaincfg=$CFG_FILE -debug -workers=${WORKERS:-1} -public=:${BLOCKBOOK_PORT} -logtostderr
