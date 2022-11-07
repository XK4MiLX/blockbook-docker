# Multicoin Blockbook Explorer
### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Required   | Default |
|----------------|----------------------------------------------|------------|---------|
|`DAEMON`| Enable/Disable daemon luncher value = 1/0  | `NO` | `1 (ENABLED)` | 
|`RPC_PORT`| Listen for RPC connections on this TCP port | `YES when DAEMON=1` | `(unset)` |
|`RPC_USER`| Listen for RPC connections on this TCP port | `YES when DAEMON=1` | `user` |
|`RPC_PASS`| Listen for RPC connections on this TCP port | `YES when DAEMON=1` | `pass` |
|`RPC_HOST`| Node hostname for blockbook | `YES` | `localhost` |
|`CONFIG`| Enable config file for daemon | `NO` | `1` |
|`EXTRACONFIG`| Additional config option. <br /> Example: "addnode=explorer.flux.zelcore.io\naddnode=explorer.runonflux.io" | `NO` | `(unset)` |


v1.0.0
