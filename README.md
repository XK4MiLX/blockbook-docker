# Multicoin Blockbook Explorer

### Pull latest image
```shell script
$ docker pull runonflux/blockbook-docker
```
### Deploy container
```shell script
docker run -d --restart=always --name fluxblockbook-flux -e COIN=flux -e DAEMON_URL=https://github.com/RunOnFlux/fluxd/releases/download/v6.0.0/Flux-amd64-v6.0.0.tar.gz -e FETCH_FILE="fetch-params.sh" -e EXTRACONFIG="addnode=explorer.flux.zelcore.io\naddnode=explorer.runonflux.io\naddnode=explorer.zelcash.online\naddnode=blockbook.runonflux.io" -e BLOCKBOOK_PORT=9158 -e RPC_PORT=16125 -p 9055:9158 -v /home/$USER/fluxdir:/root runonflux/blockbook-docker
```

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.
 
| Variable       | Description                                  | Required   | Default |
|----------------|----------------------------------------------|------------|---------|
|`COIN`| Name of coin for blockbook | `YES` | `unset` | 
|`ALIAS`| Name of coin config on blockbook github <br /> Set only if config name is diffrent then COIN | `NO` | `unset` | 
|`DAEMON`| Enable/Disable daemon luncher <br /> DISABLED=0, ENABLED=1  | `NO` | `1` | 
|`BINARY_NAME`| Name of daemon binary <br /> Use it when binary name is diffrent then <$COIN>d | `NO` | `unset` | 
|`RPC_PORT`| Listen for RPC connections on this TCP port | `YES` | `unset` |
|`RPC_USER`| Usename for RPC connections | `NO` | `user` |
|`RPC_PASS`| Password for RPC connections | `NO` | `pass` |
|`RPC_HOST`| Node hostname for blockbook | `NO` | `localhost` |
|`RPC_URL_PROTOCOL`| Protocol for RPC calls <br /> Info: ETH, ETC using ws | `NO` | `http` |
|`CONFIG`| Use Config file for daemon <br /> DISABLED=0, ENABLED=1 <br /> Info: DISABLED using cli | `NO` | `1` |
|`EXTRACONFIG`| Additional config option for daemon <br /> Example: "addnode=explorer.flux.zelcore.io\naddnode=explorer.runonflux.io" | `NO` | `unset` |
|`CLIFLAGS`| Config flags for daemon | `YES` <br />when using CLI mode | `unset` |
|`DAEMON_URL`| Download URL for daemon .tar.gz archive | `NO` | `AUTO` <br />from blockbook config |
|`FETCH_FILE`| Name of fetch parms script <br /> Example: "fetch-params.sh" | `NO` | `unset` |
|`BLOCKBOOK_PORT`| Port for blockbook. To get correct port check: <br /> https://github.com/trezor/blockbook/blob/master/docs/ports.md | `YES` | `unset` |
|`BOOTSTRAP`| Enable flux daemon bootstrapping < br /> DISABLED=0, ENABLED=1 | `NO` | `unset` |


v1.0.0
