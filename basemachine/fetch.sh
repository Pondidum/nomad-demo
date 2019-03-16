#! /bin/bash

NOMAD_VERSION=0.8.7
CONSUL_VERSION=1.4.3

OUTPUT_DIR="./binaries"

mkdir -p $OUTPUT_DIR

pushd $OUTPUT_DIR

echo "fetching Nomad..."
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip

echo "fetching Consul..."
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip

echo "fetching containerd..."
curl -sSL https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/containerd.io_1.2.4-1_amd64.deb -O

echo "fetching docker-cli..."
curl -sSL https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce-cli_18.09.3~3-0~ubuntu-xenial_amd64.deb -O

echo "fetching docker-cd..."
curl -sSL https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_18.09.3~3-0~ubuntu-xenial_amd64.deb -O

for bin in cfssl cfssl-certinfo cfssljson
do
    echo "fetching ${bin}..."
    curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > ${bin}
done

popd
