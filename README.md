# Multicoin Blockbook Explorer
### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Required   | Default |
|----------------|----------------------------------------------|------------|---------|
|`COIN`| Name of coin for blockbook  | `YES` | `(unset)` | 
|`DAEMON`| Enable/Disable daemon luncher <br /> DISABLED=0, ENABLED=1  | `NO` | `1` | 
|`RPC_PORT`| Listen for RPC connections on this TCP port | `YES when DAEMON=1` | `unset` |
|`RPC_USER`| Usename for RPC connections | `NO` | `user` |
|`RPC_PASS`| Password for RPC connections | `NO` | `pass` |
|`RPC_HOST`| Node hostname for blockbook | `YES` | `localhost` |
|`CONFIG`| Use Config file for daemon <br /> DISABLED=0, ENABLED=1 <br /> Info: DISABLED using cli | `NO` | `1` |
|`EXTRACONFIG`| Additional config option <br /> Example: "addnode=explorer.flux.zelcore.io\naddnode=explorer.runonflux.io" | `NO` | `(unset)` |
|`DAEMON_URL`| Download URL for daemon .tar.gz archive | `YES when DAEMON=1 | `unset` |


v1.0.0
