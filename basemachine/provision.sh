#! /bin/bash

# Update apt and get dependencies
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    curl \
    vim \
    apt-transport-https \
    ca-certificates \
    software-properties-common

LOCAL_DOWNLOAD=1

# Download Nomad
NOMAD_VERSION=0.8.7
CONSUL_VERSION=1.4.3

cd /tmp/

if [ $LOCAL_DOWNLOAD -eq "1" ]; then
    echo "Fetching Nomad from /vagrant/binaries"
    cp /vagrant/binaries/nomad.zip nomad.zip

    echo "Fetching Consul from /vagrant/binaries"
    cp /vagrant/binaries/consul.zip consul.zip
else
    echo "Fetching Nomad from Hashicorp..."
    curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip

    echo "Fetching Consul from Hashicorp..."
    curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
fi

echo "Installing Nomad..."
unzip nomad.zip
sudo install nomad /usr/bin/nomad

sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d

echo "Installing Docker..."
if [ $LOCAL_DOWNLOAD -eq "1" ]; then
    echo "installing from /vagrant/binaries"
    sudo dpkg -i /vagrant/binaries/containerd.io_1.2.4-1_amd64.deb
    sudo dpkg -i /vagrant/binaries/docker-ce-cli_18.09.3~3-0~ubuntu-xenial_amd64.deb
    sudo dpkg -i /vagrant/binaries/docker-ce_18.09.3~3-0~ubuntu-xenial_amd64.deb
else
    if [[ -f /etc/apt/sources.list.d/docker.list ]]; then
        echo "Docker repository already installed; Skipping"
    else
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce
fi

# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart

# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant

echo "Installing Consul..."
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul

for bin in cfssl cfssl-certinfo cfssljson
do
    echo "Installing $bin..."
    if [ $LOCAL_DOWNLOAD -eq "1" ]; then
        sudo install /vagrant/binaries/${bin} /usr/local/bin/${bin}
    else
        curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
        sudo install /tmp/${bin} /usr/local/bin/${bin}
    fi
done

echo "Installing autocomplete..."
nomad -autocomplete-install

echo "installing dotnet core..."
wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo DEBIAN_FRONTEND=noninteractive apt-get install apt-transport-https -y
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install aspnetcore-runtime-2.2 -y
