#!/bin/bash

#
wget https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/observerSetup.sh -O /users/JM941935/observerSetup.sh
wget https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/monitor.sh -O /users/JM941935/monitor.sh

# 
echo 'installing software...'
sudo apt-get remove -y --purge man-db
sudo apt-get update
sudo apt install -y nfs-kernel-server

# 
echo 'making share directory...'
mkdir '/var/webserver_monitor'
chown -R nobody:nogroup '/var/webserver_monitor'
chmod 777 '/var/webserver_monitor'

# 
echo 'editing nfs config @ /etc/exports...'
echo '/var/webserver_monitor 192.168.1.1(rw,sync,no_root_squash,no_subtree_check)' >> '/etc/exports'

# 
echo 'configuring firewall...'
ufw enable
ufw allow from 192.168.1.1 to any port nfs

# 
echo 'restarting nfs-kernel-server...'
exportfs -a
systemctl restart nfs-kernel-server && sleep 1
