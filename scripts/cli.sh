#! /bin/bash

set -e

nomad_server=$(cat server_ip)

echo 'export NOMAD_ADDR="http://$(cat server_ip):4646"'
export NOMAD_ADDR="http://$nomad_server:4646"

echo ""
echo "Checking nomad communication..."
nomad status

sleep 10s

echo "registering artifact server into consul"
curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "artifacts", "Name": "artifacts", "Port": 3030 }'

echo "registering docker registry into consul"
curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "registry", "Name": "registry", "Port": 5000 }'

echo ""
echo "Launching browser tabs..."
start http://localhost:8500
start $NOMAD_ADDR
