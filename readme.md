# Vault Demo

Repository to go with my talk on [Nomad: Kubernetes without the Complexity](https://andydote.co.uk/presentations/index.html?nomad) (**not published yet**).

## Requirements

* Hyper-v
* Vagrant
* Nomad
* Bash

Optionals:
* Consul
* Tmux

## Setup

1. create the basemachine:
    ```shell
    cd ./basemachine
    ./fetch.sh
    ./export.sh
    ```
1. start the cluster
    ```shell
    vagrant up
    ```
1. Run all the demo junk
    * if you have tmux:
        ```shell
        ./scripts/demo.sh
        ```
    * if you don't, run a separate shell for each of these:
        * `./scripts/artifacts.sh`
        * `./scripts/registry.sh`
        * `./scripts/consul.sh`
1. in an admin shell, run this:
    ```shell
    export NOMAD_ADDR="http://$(cat server_ip):4646"
    nomad status
    ```

Good Luck!
