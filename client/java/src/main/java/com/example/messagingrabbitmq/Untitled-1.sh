
rabbitmqctl add_user guest guest
rabbitmqctl set_user_tags guest guest
rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"
