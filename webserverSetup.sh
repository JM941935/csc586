#!/bin/bash

# 
wget https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/scan.sh -O /users/JM941935/scan.sh
chmod +x /users/JM941935/scan.sh

# remove man-db because its slow
echo 'removing man-db...'
apt-get remove -y --purge man-db

# 
echo 'installing packages...'
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-cli php-mysql php-cgi php-curl php-json php-apcu php-gd php-xml php-mbstring php-gettext nfs-common geoip-bin
systemctl start apache2 && sleep 1

# 
echo 'creating /var/webserver_log...'
mkdir -p '/var/webserver_log'
chmod 777 '/var/webserver_log'

# 
echo 'creating /var/webserver_log/unauthorized.log...'
bash -c 'touch "/var/webserver_log/unauthorized.log"'
chmod 777 '/var/webserver_log/unauthorized.log'

#
echo 'mounting /var/webserver_log...'
mount 192.168.1.2:/var/webserver_monitor /var/webserver_log
