#! /bin/bash

registry=$(docker run -d --rm -p 5000:5000 registry:latest)

docker tag rabbitmq:consul localhost:5000/pondidum/rabbitmq:consul
docker push localhost:5000/pondidum/rabbitmq:consul

read -n 1 -s -r

docker stop $registry
