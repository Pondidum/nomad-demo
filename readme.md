# Vault Demo

Repository to go with my talk on [Nomad: Kubernetes without the Complexity](https://andydote.co.uk/presentations/index.html?nomad) (**not published yet**).

## Tooling

Required:
* Hyper-v - You can adapt the `Vagrantfile`s to other virtualisation tools if you want
* [Vagrant](https://www.vagrantup.com/) - for the VMs
* [Nomad](https://www.nomadproject.io/) - to interact with the cluster
* Bash - gitbash is fine

Optionals:
* [Consul](https://www.consul.io) - run a consul node on your local machine to host other services
* Tmux - just makes running one of the scripts easier

## Setup

1. create the basemachine:
    ```shell
    cd ./basemachine
    ./fetch.sh
    ./export.sh
    ```
1. start the cluster
    ```shell
    ./scripts/init.sh
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
    You can now run jobs:
    ```shell
    nomad job run rabbit/rabbit.nomad
    ```


Good Luck!
