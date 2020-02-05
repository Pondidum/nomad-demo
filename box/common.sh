#!/bin/bash -e

echo "==> Configuring Consul"
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

sleep 2 # allow agent to start

echo "    waiting for cluster to form"
while [ "$(consul operator raft list-peers | grep -c leader)" != "1" ]; do
  sleep 1
done

echo "    Done"

echo "==> Configuring Vault"

(
cat <<EOF
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}
EOF
) | tee /etc/vault/vault.hcl

rc-update add vault
rc-service vault start

sleep "$(( ( $RANDOM % 5 )  + 1 ))s"

export VAULT_ADDR="http://localhost:8200"

if
  consul lock \
  -child-exit-code \
  vagrant/init-lock \
  "vault operator init -key-shares=1 -key-threshold=1 -format=json 1> /tmp/vault_init 2>/dev/null";
then
  echo "    Initialised Vault"
  init_json=$(cat /tmp/vault_init)
  consul kv put vagrant/init "$init_json"
else
  echo "    Already initialised"
  sleep 2s
  init_json=$(consul kv get vagrant/init)
fi

root_token=$(echo "$init_json" | jq -r .root_token)
unseal_key=$(echo "$init_json" | jq -r .unseal_keys_b64[0])

echo "    Root Token: $root_token"
echo "    Unseal Key: $unseal_key"

vault operator unseal "$unseal_key"

echo "    Vault Unsealed"

echo "==> Configuring Nomad"

export VAULT_TOKEN="$root_token"
escaped_token=$(echo "$root_token" | sed -e 's/[\/&]/\\&/g')

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

vault {
    enabled = true
    address = "http://vault.service.consul:8200"
    token = "$escaped_token"
}
EOF
) | tee /etc/nomad/nomad.hcl

rc-update add nomad
rc-service nomad start

echo "    Nomad started"

echo "==> Configuring Docker"

echo '
{
    "insecure-registries": [
        "registry.service.consul:5000"
    ],
    "dns": [
      "192.168.121.1"
    ]
}' | tee /etc/docker/daemon.json

rc-service docker restart

echo "==> Exporting machine info"

rm -f "/vagrant/.machine/$HOSTNAME"
echo "export VAULT_ADDR=http://$HOSTNAME.karhu.xyz:8200" >> "/vagrant/.machine/$HOSTNAME"
echo "export VAULT_TOKEN=$root_token" >> "/vagrant/.machine/$HOSTNAME"
echo "export VAULT_UNSEAL=$unseal_key" >> "/vagrant/.machine/$HOSTNAME"
echo "export NOMAD_ADDR=http://$HOSTNAME.karhu.xyz:8200" >> "/vagrant/.machine/$HOSTNAME"
