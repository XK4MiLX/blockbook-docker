#!/usr/bin/env bash
#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WORNING="${RED}\xF0\x9F\x9A\xA8${NC}"
RIGHT_ANGLE="${GREEN}\xE2\x88\x9F${NC}"
server_offline="0"
failed_counter="0"

function tar_file_unpack()
{
    echo -e "${ARROW} ${CYAN}Unpacking bootstrap archive file...${NC}"
    pv $1 | tar -zx -C $2
}

function cdn_speedtest() {
	if [[ -z $1 || "$1" == "0" ]]; then
		BOOTSTRAP_FILE="flux_explorer_bootstrap.tar.gz"
	else
		BOOTSTRAP_FILE="$1"
	fi
	if [[ -z $2 ]]; then
		dTime="5"
	else
		dTime="$2"
	fi
	if [[ -z $3 ]]; then
		rand_by_domain=("5" "6" "7" "8" "9" "10" "11" "12")
	else
		msg="$3"
		shift
		shift
		rand_by_domain=("$@")
		custom_url="1"
	fi
	size_list=()
	i=0
	len=${#rand_by_domain[@]}
	echo -e "${ARROW} ${CYAN}Running quick download speed test for ${BOOTSTRAP_FILE}, Servers: ${GREEN}$len${NC}"
	start_test=`date +%s`
	while [ $i -lt $len ];
   do
		if [[ "$custom_url" == "1" ]]; then
			testing=$(curl -m ${dTime} ${rand_by_domain[$i]}${BOOTSTRAP_FILE}  --output testspeed -fail --silent --show-error 2>&1)
		else
			testing=$(curl -m ${dTime} http://cdn-${rand_by_domain[$i]}.runonflux.io/apps/fluxshare/getfile/${BOOTSTRAP_FILE}  --output testspeed -fail --silent --show-error 2>&1)
		fi
		testing_size=$(grep -Po "\d+" <<< "$testing" | paste - - - - | awk '{printf  "%d\n",$3}')
		mb=$(bc <<<"scale=2; $testing_size / 1048576 / $dTime" | awk '{printf "%2.2f\n", $1}')
		if [[ "$custom_url" == "1" ]]; then
			domain=$(sed -e 's|^[^/]*//||' -e 's|/.*$||' <<< ${rand_by_domain[$i]})
			echo -e "  ${RIGHT_ANGLE} ${GREEN}URL - ${YELLOW}${domain}${GREEN} - Bits Downloaded: ${YELLOW}$testing_size${NC} ${GREEN}Average speed: ${YELLOW}$mb ${GREEN}MB/s${NC}"
		else
			echo -e "  ${RIGHT_ANGLE} ${GREEN}cdn-${YELLOW}${rand_by_domain[$i]}${GREEN} - Bits Downloaded: ${YELLOW}$testing_size${NC} ${GREEN}Average speed: ${YELLOW}$mb ${GREEN}MB/s${NC}"
		fi
		size_list+=($testing_size)
		if [[ "$testing_size" == "0" ]]; then
			failed_counter=$(($failed_counter+1))
		fi
		i=$(($i+1))
	done
	rServerList=$((${#size_list[@]}-$failed_counter))
	echo -e "${ARROW} ${CYAN}Valid servers: ${GREEN}${rServerList} ${CYAN}- Duration: ${GREEN}$((($(date +%s)-$start_test)/60)) min. $((($(date +%s)-$start_test) % 60)) sec.${NC}"
	rm -rf testspeed > /dev/null 2>&1
	if [[ "$rServerList" == "0" ]]; then
	server_offline="1"
	return 
	fi
	arr_max=$(printf '%s\n' "${size_list[@]}" | sort -n | tail -1)
	for i in "${!size_list[@]}"; do
		[[ "${size_list[i]}" == "$arr_max" ]] &&
		max_indexes+=($i)
	done
	server_index=${rand_by_domain[${max_indexes[0]}]}
	if [[ "$custom_url" == "1" ]]; then
		BOOTSTRAP_URL="$server_index"
	else
		BOOTSTRAP_URL="http://cdn-${server_index}.runonflux.io/apps/fluxshare/getfile/"
	fi
	DOWNLOAD_URL="${BOOTSTRAP_URL}${BOOTSTRAP_FILE}"
   #Print the results
	mb=$(bc <<<"scale=2; $arr_max / 1048576 / $dTime" | awk '{printf "%2.2f\n", $1}')
	if [[ "$custom_url" == "1" ]]; then
		domain=$(sed -e 's|^[^/]*//||' -e 's|/.*$||' <<< ${server_index})
		echo -e "${ARROW} ${CYAN}Best server is: ${YELLOW}${domain} ${GREEN}Average speed: ${YELLOW}$mb ${GREEN}MB/s${NC}"
	else
		echo -e "${ARROW} ${CYAN}Best server is: ${GREEN}cdn-${YELLOW}${rand_by_domain[${max_indexes[0]}]} ${GREEN}Average speed: ${YELLOW}$mb ${GREEN}MB/s${NC}"
	fi
}

if [[ "$BINARY_NAME" == "" ]]; then
  BINARY_NAME="${COIN}d"
fi

stop_script() {
  echo -e "Stopping daemon (EXIT)..."
  if [[ "$BINARY_NAME" == "${COIN}d" ]]; then
    timeout 10 ${COIN}-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" stop
  fi
  pkill -9 $BINARY_NAME
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

#ONLY FLUX
if [[ "$BOOTSTRAP" == "1" && "$COIN" == "flux" && ! -f /root/BOOTSTRAP_LOCKED ]]; then
    echo -e ""
    cdn_speedtest "0" "6"
    if [[ "$server_offline" == "1" ]]; then
      echo -e "${WORNING} ${CYAN}All Bootstrap server offline, operation aborted.. ${NC}" && sleep 1
    else
      cd /root
      echo -e "${ARROW} ${YELLOW}Downloading File: ${GREEN}$DOWNLOAD_URL ${NC}"
      wget --tries 5 -O $BOOTSTRAP_FILE $DOWNLOAD_URL -q --no-verbose --show-progress --progress=dot:giga > /dev/null 2>&1
      tar_file_unpack "/root/$BOOTSTRAP_FILE" "/root/.flux"
      echo -e "Bootstrap [LOCKED]" > BOOTSTRAP_LOCKED
      rm -rf /root/$BOOTSTRAP_FILE
      sleep 2
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
  if [[ "$BINARY_NAME" == "${COIN}d" ]]; then
    timeout 10 ${COIN}-cli -rpcpassword="$RPC_PASS" -rpcuser="$RPC_USER" stop
  fi
  pkill -9 ${BINARY_NAME}
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
  strip_lvl=$(tar -tvf ${DAEMON_URL##*/} | grep ${BINARY_NAME}$ | awk '{ printf "%s\n", $6 }' | awk -F\/ '{print NF-1}')
  tar --exclude="share" --exclude="lib" --exclude="include" -C backend --strip $strip_lvl -xf ${DAEMON_URL##*/}
  echo -e "Installing daemon ($COIN)..."
  install -m 0755 -o root -g root -t /usr/local/bin backend/*
  rm -rf /tmp/*
fi

cd /
sleep 5
if [[ "$CONFIG" == "0" || "$CONFIG" == "" ]]; then
  echo -e "Starting $COIN daemon (Config: Disabled)..."
  ${BINARY_NAME} ${CLIFLAGS}
else
  echo -e "Starting $COIN daemon (Config: Enabled)..."
  ${BINARY_NAME}
fi
else
  echo -e "Daemon Luncher is disabled..."
  exit
fi
