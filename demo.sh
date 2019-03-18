#! /bin/bash

netsh interface ip show addresses "vEthernet (Default Switch)" \
    | sed -n 's/.*IP Address:\s*//p' \
    > host_ip

registry=$(docker run -d --rm -p 5000:5000 registry:latest)

docker tag rabbitmq:consul localhost:5000/rabbitmq:consul
docker push localhost:5000/rabbitmq:consul

nws -d ./app &
nws_pid=$!


vagrant up


consul agent \
    -client 0.0.0.0 \
    -bind "$(cat host_ip)" \
    -join "$(cat server_ip)" \
    -data-dir /d/tmp/consul/ \
    -ui \
    &
#    &>/dev/null &
consul_pid=$!

sleep 5s

echo "registering artifact server into consul"
curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "artifacts", "Name": "artifacts", "Port": 3030 }'


echo "any key to kill things"
read -n 1 -s -r

kill $nws_pid
kill $consul_pid

docker stop $registry
