###################################################################################################
Scenario1 
###################################################################################################
https://medium.com/@saurabh.singh0829/how-to-create-rabbitmq-cluster-in-docker-aws-linux-4b26a31f90bc


docker info

docker network create mynet

docker network inspect mynet


docker run -d --hostname rabbit1 --name myrabbit1 -p 15672:15672 -p 5672:5672 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management
docker run -d --hostname rabbit2 --name myrabbit2 -p 5673:5672 --link myrabbit1:rabbit1 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management
docker run -d --hostname rabbit3 --name myrabbit3 -p 5674:5672 --link myrabbit1:rabbit1 --link myrabbit2:rabbit2 --network mynet -e RABBITMQ_ERLANG_COOKIE=rabbitcookie rabbitmq:management

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


-----------

###################################################################################################
Scenario2
###################################################################################################
https://blexin.com/en/blog-en/high-availability-with-rabbitmq/

docker info

docker network create mynetrmq

docker network inspect mynetrmq

docker stop rabbitNode1 rabbitNode2
docker rm rabbitNode1 rabbitNode2
sudo rm -rf rmq1/data rmq2/data rmq1/logs rmq2/logs
mkdir -p rmq1/data rmq2/data rmq1/logs rmq2/logs

export RMQ_LOCALDIR=/home/elmos/work/docker/pepit-rmq

#Not used following
#            -e  RABBITMQ_ERLANG_COOKIE=rabbitcookie2021\
docker run -d -h rabbitHost1 --network mynetrmq \
           --name rabbitNode1 \
           -v $RMQ_LOCALDIR/rmq1/data:/var/lib/rabbitmq \
           -v $RMQ_LOCALDIR/rmq1/logs:/var/log/rabbitmq/log \
           -p "4469:4369"\
           -p "5672:5672"\
           -p "15672:15672"\
           -p "25672:25672"\
           -p "35672:35672"\
           -e RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="--erlang-cookie rabbitcookie"\
           -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=Admin123\
           rabbitmq:management
  
docker logs rabbitNode1


docker run -d -h rabbitHost2 --network mynetrmq  --link rabbitNode1:rabbitHost1 \
           --name rabbitNode2\
           -v $RMQ_LOCALDIR/rmq1/data:/var/lib/rabbitmq \
           -v $RMQ_LOCALDIR/rmq1/logs:/var/log/rabbitmq/log \
           -p "4470:4369"\
           -p "5673:5672"\
           -p "15673:15672"\
           -p "25673:25672"\
           -p "35673:35672"\
           -e RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="--erlang-cookie rabbitcookie"\
           -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=Admin123\
           rabbitmq:management

docker logs rabbitNode2

## fin option cookie

docker exec rabbitNode1 rabbitmqctl stop_app
docker exec rabbitNode1 rabbitmqctl reset
docker exec rabbitNode1 rabbitmqctl start_app
docker exec rabbitNode1 date;docker logs rabbitNode1 | grep "Server startup complete"

docker exec rabbitNode2 rabbitmqctl stop_app
docker exec rabbitNode2 rabbitmqctl reset

docker exec rabbitNode2 rabbitmqctl join_cluster rabbit@rabbitHost1

docker exec rabbitNode2 rabbitmqctl start_app
docker exec rabbitNode2 date;docker logs rabbitNode2 | grep "Server startup complete"

docker exec rabbitNode1 rabbitmqctl cluster_status
docker exec rabbitNode2 rabbitmqctl cluster_status

docker exec rabbitNode1 rabbitmqctl set_policy ha "." '{"ha-mode":"all"}'


###################################################################################################
Scenario3
###################################################################################################
https://blexin.com/en/blog-en/high-availability-with-rabbitmq/


docker network create --subnet=192.168.0.0/16 cluster-network

export RMQ_LOCALDIR=/home/elmos/work/docker/pepit-rmq

docker run -d -h node1.rabbit \
           --net cluster-network --ip 192.168.0.10 \
           --name rabbitNode1 \
           --add-host node2.rabbit:192.168.0.11\
           -v $RMQ_LOCALDIR/rmq1/data:/var/lib/rabbitmq \
           -v $RMQ_LOCALDIR/rmq1/logs:/var/log/rabbitmq/log \
           -p "4469:4369"\
           -p "5672:5672"\
           -p "15672:15672"\
           -p "25672:25672"\
           -p "35672:35672"\
           -e "RABBITMQ_USE_LONGNAME=true"\
           -e RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="--erlang-cookie rabbitcookie"\
           -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=Admin123\
           rabbitmq:management
  
  
docker run -d -h node2.rabbit\
           --net cluster-network --ip 192.168.0.11\
           --name rabbitNode2\
           --add-host node1.rabbit:192.168.0.10\
           -v $RMQ_LOCALDIR/rmq1/data:/var/lib/rabbitmq \
           -v $RMQ_LOCALDIR/rmq1/logs:/var/log/rabbitmq/log \
           -p "4470:4369"\
           -p "5673:5672"\
           -p "15673:15672"\
           -p "25673:25672"\
           -p "35673:35672"\
           -e "RABBITMQ_USE_LONGNAME=true"\
           -e RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="--erlang-cookie rabbitcookie"\
           -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=Admin123\
           rabbitmq:management

docker exec rabbitNode1 rabbitmqctl stop_app
docker exec rabbitNode1 rabbitmqctl reset
docker exec rabbitNode1 rabbitmqctl start_app


docker exec rabbitNode2 rabbitmqctl stop_app
docker exec rabbitNode2 rabbitmqctl reset

docker exec rabbitNode2 rabbitmqctl join_cluster rabbit@rabbitHost1

docker exec rabbitNode2 rabbitmqctl start_app

docker exec rabbitNode1 rabbitmqctl cluster_status
docker exec rabbitNode2 rabbitmqctl cluster_status

docker exec rabbitNode1 rabbitmqctl set_policy ha "." '{"ha-mode":"all"}'



###
