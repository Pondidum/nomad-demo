#! /bin/bash

set -e

nomad_server=$(cat server_ip)

echo 'export NOMAD_ADDR="http://$(cat server_ip):4646"'
export NOMAD_ADDR="http://$nomad_server:4646"

echo ""
echo "Checking nomad communication..."
nomad status

echo ""
echo "Launching browser tabs..."
start http://localhost:8500
start $NOMAD_ADDR
