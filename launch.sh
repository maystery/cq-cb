#!/bin/bash
IP=`curl ifconfig.me`

docker run -d -p 8080:8080 -e BROKER=amqp://guest:guest@$IP:5672 -e RESULT_BACKEND=redis://$IP:6379 --restart=always emodimark/cqueue_frontend
docker run -d -p 15672:15672 -p 5672:5672 -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest --restart=always  rabbitmq:3-management
docker run -d -p 6379:6379 --restart=always redis redis-server --appendonly yes
docker run --name worker -d -e BROKER=amqp://guest:guest@$IP:5672 -e RESULT_BACKEND=redis://$IP:6379 -e AMQP_PREFETCH_COUNT=1 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker emodimark/cqueue_worker
