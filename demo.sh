#! /bin/bash

host_ip=$(netsh interface ip show addresses "vEthernet (Default Switch)" \
    | sed -n 's/.*IP Address:\s*//p')

echo "$host_ip" > host_ip

registry=$(docker run -d --rm -p 5000:5000 registry:latest)

docker tag rabbitmq:consul localhost:5000/pondidum/rabbitmq:consul
docker push localhost:5000/pondidum/rabbitmq:consul

nws -d ./app &
nws_pid=$!


vagrant up


consul_data="/d/tmp/consul/"
consul agent \
    -client 0.0.0.0 \
    -bind "$(cat host_ip)" \
    -join "$(cat server_ip)" \
    -data-dir "$consul_data" \
    -ui \
    &
consul_pid=$!

sleep 5s

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

echo "any key to kill things"

echo "consul: $consul_pid"
echo "nws: $nws_pid"

read -n 1 -s -r

kill $consul_pid

rm -rf "$consul_data"
docker stop $registry

kill $nws_pid
