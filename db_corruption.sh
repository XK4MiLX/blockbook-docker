#!/bin/bash

if [[ -f /root/blockbook.log ]]; then
  echo -e "-------------------------------------------------------------[START]"
  echo -e "| Checking blockbook logs...."
  WALs_CHECK=$(grep -o "rocksDB: Corruption: SST file is ahead of WALs in CF" /root/blockbook.log)
  if [[ "$WALs_CHECK" != "" ]]; then
    echo -e "| RocksDB Corruption detected!..."
    echo -e "| Stopping blockbook service..."
    supervisorctl stop blockbook > /dev/null 2>&1
    echo -e "| Repair the database..."
    ./opt/blockbook/blockbook -repair -datadir=/root/blockbook-db
    echo -e "| Starting blockbook service..."
    supervisorctl start blockbook > /dev/null 2>&1
  fi
  echo -e "----------------------------------------------------------------[END]"
fi
