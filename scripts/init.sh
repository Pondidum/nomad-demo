#! /bin/bash

set -e

if [ -x "$(command -v netsh)" ]; then
    host_ip=$(netsh interface ip show addresses "vEthernet (Default Switch)" \
        | sed -n 's/.*IP Address:\s*//p')
else
	host_ip=$(ifconfig virbr0 | grep -hoP 'inet \K(.*?)(?= )')
fi

echo "$host_ip" > host_ip
echo "host IP: $host_ip"
