#!/bin/bash

# remove man-db because its slow
echo 'removing man-db...'
apt-get remove -y --purge man-db

# 
echo 'installing packages...'
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-cli php-mysql php-cgi php-curl php-json php-apcu php-gd php-xml php-mbstring php-gettext nfs-common
systemctl start apache2 && sleep 1

# 
echo 'creating /var/webserver_monitor...'
mkdir '/var/webserver_monitor'

#
echo 'mounting /var/webserver_monitor...'
mount 192.168.1.2:/var/webserver_monitor /var/webserver_monitor
