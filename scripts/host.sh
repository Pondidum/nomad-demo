#! /bin/bash

set -e

docker run -d --rm \
    --name nomad-registry \
    -p 5000:5000 \
    registry:latest

docker run -d --rm \
    --name nomad-artifacts \
    -p 3030:3030 \
    -e 'PORT=3030' \
    -v $PWD/app:/web \
    halverneus/static-file-server:latest

echo "pushing consul image to local repository"
docker tag rabbitmq:consul localhost:5000/pondidum/rabbitmq:consul
docker push localhost:5000/pondidum/rabbitmq:consul

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
