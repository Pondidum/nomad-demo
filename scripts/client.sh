#! /bin/bash

host_ip=$(cat /vagrant/host_ip)
this_ip=$1

if [ "$this_ip" == "" ]; then
    this_ip=$(ip route get 1 | awk '{print $NF;exit}')
fi

echo "$host_ip	artifacts.service.consul" | sudo tee --append /etc/hosts
echo "$host_ip	registry.service.consul" | sudo tee --append /etc/hosts

(
cat <<-EOF
    [Unit]
    Description=consul agent
    Requires=network-online.target
    After=network-online.target

    [Service]
    Restart=on-failure
    ExecStart=/usr/bin/consul agent -client 0.0.0.0 -bind $this_ip -data-dir /tmp/consul-data -join $(cat /vagrant/server_ip)
    ExecReload=/bin/kill -HUP $MAINPID

    [Install]
    WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service

sudo systemctl enable consul.service
sudo systemctl start consul

sleep 5


host_only_adaptor=$(ifconfig | grep -B1 "inet addr:$this_ip" | awk '$1!="inet" && $1!="--" {print $1}')

(
cat <<-EOF
    data_dir = "/opt/nomad/data"
    bind_addr = "$this_ip"

    client {
        enabled = true
        network_interface = "$host_only_adaptor"
    }

    consul {
        address = "127.0.0.1:8500"
    }
EOF
) | sudo tee /etc/nomad.d/nomad.hcl

(
cat <<-EOF
    [Unit]
    Description=nomad server and client
    Requires=network-online.target
    After=network-online.target

    [Service]
    Restart=on-failure
    ExecStart=/usr/bin/nomad agent -join nomad.service.consul:4646 -config /etc/nomad.d
    ExecReload=/bin/kill -HUP $MAINPID
    User=root
    Group=root

    [Install]
    WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service

sudo systemctl enable nomad.service
sudo systemctl start nomad

# docker registry

echo '
{
    "insecure-registries" : [
        "'$host_ip':5000",
        "registry.service.consul:5000"
    ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
