#!/bin/bash

# 
echo 'installing packages'
sudo apt-get remove -y --purge man-db && apt-get install man-db
sudo apt-get update
sudo apt install -y nfs-kernel-server mailutils

# 
echo 'creating shared directory'
mkdir -p '/var/webserver_monitor' && echo 'created shared directory /var/webserver_monitor'
chown -R nobody:nogroup '/var/webserver_monitor' && echo 'changed owner of /var/webserver_monitor to nobody'
chmod 777 '/var/webserver_monitor' && echo 'changed permissions on /var/webserver_monitor to 777'

# 
echo 'editing nfs config'
echo '/var/webserver_monitor 192.168.1.1(rw,sync,no_root_squash,no_subtree_check)' >> '/etc/exports'
if grep -q '/var/webserver_monitor' '/etc/exports'; then (echo 'updated nfs config /etc/exports'); fi

# 
echo 'configuring firewall'
ufw enable && echo 'firewall enabled'
ufw allow from 192.168.1.1 to any port nfs && echo 'allowed 192.168.1.1 through the firewall'

# 
echo 'exporting nfs paths'
exportfs -a && echo 'exported nfs paths'

# 
echo 'restarting nfs-kernel-server'
systemctl restart nfs-kernel-server && sleep 1

#
echo 'creating body.txt'
(bash -c 'touch body.txt' && sleep 1) && echo 'created body.txt'
chmod 666 'body.txt' && echo 'changed permissions on body.txt to 666'
