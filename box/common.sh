#!/bin/sh -eu

(
cat <<-EOF
{
  "data_dir": "/var/consul",
  "client_addr": "127.0.0.1 {{ GetInterfaceIP \"eth0\" }}",
  "bind_addr": "{{ GetInterfaceIP \"eth0\" }}",
  "ui": true,
  "server": true,
  "bootstrap_expect": 3,
  "retry_join": [ "one.karhu.xyz", "two.karhu.xyz", "three.karhu.xyz" ],
  "connect": {
    "enabled": true
  }
}
EOF
) | tee /etc/consul/consul.json

rc-update add consul
rc-service consul start

sleep 10

(
cat <<-EOF
data_dir = "/var/nomad"

client {
    enabled = true
}

server {
    enabled = true
    bootstrap_expect = 3
}
EOF
) | tee /etc/nomad/nomad.hcl

rc-update add nomad
rc-service nomad start

echo '
{
    "insecure-registries" : [
        "registry.service.consul:5000"
    ]
}' | tee /etc/docker/daemon.json

rc-service docker restart
