#!/bin/bash

set -e

echo "==> Configuring host containers"
machine_ip=$(ip route get 1 | awk '{print $(NF-2);exit}')

echo "    HostIP: $machine_ip"

echo "    Running Consul"
docker run -d --rm \
    --name nomad-consul \
    --net=host \
    -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' \
    consul agent -bind="$machine_ip" -retry-join="one.karhu.xyz"

echo "    Running docker registry"
docker run -d --rm \
    --name nomad-registry \
    -p 5000:5000 \
    registry:latest

echo "    Running http artifacts server"
docker run -d --rm \
    --name nomad-artifacts \
    -p 3000:3000 \
    -e 'PORT=3000' \
    -v "$PWD/.artifacts:/web" \
    halverneus/static-file-server:latest

echo "==> Pusing rabbitmq:consul to docker registry"
docker tag rabbitmq:consul localhost:5000/pondidum/rabbitmq:consul
docker push localhost:5000/pondidum/rabbitmq:consul

echo "==> Registering services into Consul"

echo "    http artifacts host"
curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "artifacts", "Name": "artifacts", "Port": 3000 }'

echo "    docker registry"
curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "registry", "Name": "registry", "Port": 5000 }'

echo "==> Consul Status"

consul members

echo "==> Done."
