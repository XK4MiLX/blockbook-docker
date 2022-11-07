# Multicoin Blockbook Explorer
### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Required   | Default |
|----------------|----------------------------------------------|------------|---------|
|`DAEMON`| Enable/Disable daemon luncher value = 1/0  | `NO` | `1 (ENABLED)` | 
|`RPC_PORT`| Listen for RPC connections on this TCP port | `YES when DAEMON=1` | `(unset)` |
|`RPC_HOST`| Node hostname for blockbook | `YES` | `localhost` |


v1.0.0
