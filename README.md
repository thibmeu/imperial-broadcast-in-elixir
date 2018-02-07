# Distributed Algorithms 347

## Coursework 1

### Thibault Meunier (ttm17)



### Run the system

Project architecture has been inspired by `lab02`

```bash
cd 1_elixir_broadcast   # Mix project directory of project 1, same for other sections
make compile            # Mix compile with proper parameters
make run                # Run project locally
make up                 # Run project on a docker network
```

### System variables

Each system can be modified using different variables.

| Variable       | Meaning                              | File            | Available from |
| -------------- | ------------------------------------ | --------------- | -------------- |
| `PEERS`        | Number of peers in the system        | `Makefile`      | System1        |
| `max_messages` | Maximum number of broadcast          | `lib/system.ex` | System1        |
| `timeout`      | Maximum period of broadcast          | `lib/system.ex` | System1        |
| `reliability`  | Percentage of outgoing messages sent | `lib/pl.ex`     | System4        |

