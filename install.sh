    #!/bin/bash

    # README
    # ONLY VARIABLE REQUIRED IS admin password for "rabbitmqctl add_user admin {MyPassword}"
    # PLease change before running script.
    #
#ROOT##############################
 groupadd rabbitmq
 useradd -g rabbitmq -s /bin/bash rabbitmq
 mkdir -p /home/rabbitmq/etc
 mkdir -p /home/rabbitmq/src
 chown -R rabbitmq:rabbitmq /home/rabbitmq


 passwd rabbitmq


cd /home/rabbitmq/src

    echo "#######################################################################";
    echo "This script will install RabbitMQ 3.7.9 and open relevant firewall rules";
    echo "#######################################################################";


    yum -y install epel-release

    wget https://packages.erlang-solutions.com/erlang-solutions-2.0-1.noarch.rpm
    rpm -Uvh erlang-solutions-2.0-1.noarch.rpm


    yum -y install erlang socat logrotate


    #wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.9/rabbitmq-server-3.7.9-1.el7.noarch.rpm
    wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.14/rabbitmq-server-3.8.14-1.el8.noarch.rpm

    rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    #rpm --import https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.14/rabbitmq-server-3.8.14-1.el8.noarch.rpm.asc

    #rpm -Uvh rabbitmq-server-3.7.9-1.el7.noarch.rpm
    rpm -Uvh rabbitmq-server-3.8.14-1.el8.noarch.rpm

    ##copy /home/rabbitmq here and modiy path in rabbitmq.con 



    echo "
    # Example rabbitmq-env.conf file entries. Note that the variables
    # do not have the RABBITMQ_ prefix.
    #
    # Overrides node name
    NODENAME=rabbit@centosboxpro

    # Specifies new style config file location
    CONFIG_FILE=/home/rabbitmq/etc/rabbitmq.conf

    # Specifies advanced config file location
    #ADVANCED_CONFIG_FILE=/etc/rabbitmq/advanced.config

    " >>  /etc/rabbitmq/rabbitmq-env.conf

 #   chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

    systemctl start rabbitmq-server
    rabbitmq-plugins enable rabbitmq_management

# From user rabbitmq
    echo "

    listeners.ssl.default = 5673

    ssl_options.cacertfile = /home/rabbitmq/ALLCERTS/ca_certificate.pem
    ssl_options.certfile   = /home/rabbitmq/ALLCERTS/server_certificate.pem
    ssl_options.keyfile    = /home/rabbitmq/ALLCERTS/private_key.pem
    ssl_options.verify     = verify_peer
    ssl_options.fail_if_no_peer_cert = true

    management.ssl.port       = 15673
    management.ssl.cacertfile = /home/rabbitmq/ALLCERTS/ca_certificate.pem
    management.ssl.certfile   = /home/rabbitmq/ALLCERTS/server_certificate.pem
    management.ssl.keyfile    = /home/rabbitmq/ALLCERTS/private_key.pem
    ## This key must only be used if private key is password protected
    # management.ssl.password   = bunnies

    # For RabbitMQ 3.7.10 and later versions
    management.ssl.honor_cipher_order   = true
    management.ssl.honor_ecc_order      = true
    management.ssl.client_renegotiation = false
    management.ssl.secure_renegotiate   = true

    management.ssl.versions.1 = tlsv1.2
    management.ssl.versions.2 = tlsv1.1

    management.ssl.ciphers.1 = ECDHE-ECDSA-AES256-GCM-SHA384
    management.ssl.ciphers.2 = ECDHE-RSA-AES256-GCM-SHA384
    management.ssl.ciphers.3 = ECDHE-ECDSA-AES256-SHA384
    management.ssl.ciphers.4 = ECDHE-RSA-AES256-SHA384
    management.ssl.ciphers.5 = ECDH-ECDSA-AES256-GCM-SHA384
    management.ssl.ciphers.6 = ECDH-RSA-AES256-GCM-SHA384
    management.ssl.ciphers.7 = ECDH-ECDSA-AES256-SHA384
    management.ssl.ciphers.8 = ECDH-RSA-AES256-SHA384
    management.ssl.ciphers.9 = DHE-RSA-AES256-GCM-SHA384

    " >> /home/rabbitmq/etc/rabbitmq.conf
    chown rabbitmq:rabbitmq /home/rabbitmq/etc/rabbitmq.conf

    #copie ALLERTCS depuis mac os 
    scp -r /Users/elmos/OneDrive/TECH/github/rabbitmq/etc/rabbitmq/ALLCERTS rabbitmq@centosboxpro:
    
    
    rabbitmq-diagnostics listeners    
    rabbitmqctl add_user admin pass2000
    rabbitmqctl set_user_tags admin administrator
    rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

    rabbitmqctl delete_user guest
 
    systemctl enable rabbitmq-server

   su elmos
    sudo su

    systemctl stop firewalld
    systemctl start firewalld

    firewall-cmd --state
    firewall-cmd --zone=public --permanent --add-port=15671-15673/tcp
    firewall-cmd --zone=public --permanent --add-port=4369/tcp
    firewall-cmd --zone=public --permanent --add-port=25672/tcp
    firewall-cmd --zone=public --permanent --add-port=5671-5673/tcp
    firewall-cmd --zone=public --permanent --add-port=61613-61614/tcp
    firewall-cmd --zone=public --permanent --add-port=1883/tcp
    firewall-cmd --zone=public --permanent --add-port=8883/tcp
    firewall-cmd --reload

