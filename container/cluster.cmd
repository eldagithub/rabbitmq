https://medium.com/@saurabh.singh0829/how-to-create-rabbitmq-cluster-in-docker-aws-linux-4b26a31f90bc


docker info

docker network create mynet

docker network inspect mynet


docker run -d --hostname rabbit1 --name myrabbit1 -p 15672:15672 -p 5672:5672 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management
docker run -d --hostname rabbit2 --name myrabbit2 -p 5673:5672 --link myrabbit1:rabbit1 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management
docker run -d --hostname rabbit3 --name myrabbit3 -p 5674:5672 --link myrabbit1:rabbit1 --link myrabbit2:rabbit2 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management

docker run -d --hostname rabbit1 --name myrabbit1 -p 15672:15672 -p 5672:5672 --network mynet rabbitmq:management
docker run -d --hostname rabbit2 --name myrabbit2 -p 5673:5672 --link myrabbit1:rabbit1 --network mynet  rabbitmq:management
docker run -d --hostname rabbit3 --name myrabbit3 -p 5674:5672 --link myrabbit1:rabbit1 --link myrabbit2:rabbit2 --network mynet rabbitmq:management


docker exec -it myrabbit1 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl start_app



docker exec -it myrabbit2 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster --ram rabbit@rabbit1
rabbitmqctl start_app



docker exec -it myrabbit3 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster --ram rabbit@rabbit1
rabbitmqctl start_app




docker run -d --hostname rabbit1 --name myrabbit1 -p 15672:15672 -p 5672:5672 --network mynet -e RABBITMQ_ERLANG_COOKIE=’rabbitcookie’ rabbitmq:management

docker run -d --hostname rabbit2 --name myrabbit2 -p 5673:5672  -e RABBITMQ_ERLANG_COOKIE=’rabbitcookie’ rabbitmq:management

docker run -d --hostname rabbit3 --name myrabbit3 -p 5674:5672  -e RABBITMQ_ERLANG_COOKIE=’rabbitcookie’ rabbitmq:management

