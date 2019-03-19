#! /bin/bash

consul_data="/d/tmp/consul/"

rm -rf "$consul_data"

consul agent \
    -client 0.0.0.0 \
    -bind "$(cat host_ip)" \
    -join "$(cat server_ip)" \
    -data-dir "$consul_data" \
    -ui
