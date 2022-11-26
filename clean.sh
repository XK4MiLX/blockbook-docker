#!/bin/bash
CLEAN=0
echo -e "| LOG CLEANER v1.0 [$(date '+%Y-%m-%d %H:%M:%S')]"
echo -e "--------------------------------------------------"
 LOG_SIZE_LIMIT=${LOG_SIZE_LIMIT:-40}
 LOG_LIST=($(find /root -type f \( -name "$COIN*.log" -o -name "debug.log" \)))
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
    echo "" > $LOG_PATH
    CLEAN=1
  fi
 done
 if [[ "$CLEAN" == "0" ]]; then
   echo -e "| All logs belown ${LOG_SIZE_LIMIT}M limit..."
 fi
 echo -e "--------------------------------------------------"
