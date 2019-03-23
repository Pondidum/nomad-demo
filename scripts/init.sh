#! /bin/bash

set -e

host_ip=$(netsh interface ip show addresses "vEthernet (Default Switch)" \
    | sed -n 's/.*IP Address:\s*//p')

echo "$host_ip" > host_ip
echo "host IP: $host_ip"
