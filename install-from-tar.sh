sudo groupadd rabbitmq
sudo useradd -g asrabbitmq -s /bin/bash rabbitmq
sudo mkdir /home/asrabbitmq
sudo chown asrabbitmq:asrabbitmq /home/asrabbitmq

sudo passwd rabbitmq

su - rabbitmq
mkdir -p apps/rabbitmq/src

cd apps/rabbitmq/src

su elmos 
sudo yum -y install epel-release
exit
wget https://packages.erlang-solutions.com/erlang-solutions-2.0-1.noarch.rpm

su elmos
sudo rpm -Uvh erlang-solutions-2.0-1.noarch.rpm

sudo yum -y install erlang socat logrotate
exit


wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.14/rabbitmq-server-generic-unix-3.8.14.tar.xz

tar xvf rabbitmq-server-generic-unix-3.8.14.tar.xz
mv rabbitmq_server-3.8.14 ../

cd ../
ln -s rabbitmq_server-3.8.14 current

cd current

echo "

export RABBITMQ_HOME=/home/asrabbitmq/apps/rabbitmq/current
export PATH=$PATH:$RABBITMQ_HOME/sbin


" >> $HOME/.profile

export RABBITMQ_HOME=/home/asrabbitmq/apps/rabbitmq/current
export PATH=$PATH:$RABBITMQ_HOME/sbin

cd etc/

#copy /etc/rabbitmq here and modiy path in rabbitmq.con 
cd rabbitmq
echo "
# Example rabbitmq-env.conf file entries. Note that the variables
# do not have the RABBITMQ_ prefix.
#
# Overrides node name
NODENAME=elmos@debianboxpro

# Specifies new style config file location
CONFIG_FILE=$RABBITMQ_HOME/etc/rabbitmq/rabbitmq.conf

# Specifies advanced config file location
#ADVANCED_CONFIG_FILE=$RABBITMQ_HOME/etc/rabbitmq/advanced.config
" >  rabbitmq-env.conf 

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



cd ../../sbin

rabbitmq-server -detached


rabbitmqctl add_user admin pass2000
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

rabbitmqctl delete_user guest
rabbitmqctl shutdown
.

