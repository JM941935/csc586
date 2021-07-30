#!/bin/bash

# owner(u)group(g)all(a)
# 0	---
# 1	--x
# 2	-w-
# 3	-wx
# 4	r--
# 5	r-x
# 6	rw-
# 7	rwx

# 
wget https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/scan.sh -O /users/JM941935/scan.sh
chmod 777 /users/JM941935/scan.sh

# remove man-db because its slow
echo 'removing man-db'
apt-get remove -y --purge man-db

# 
echo 'installing packages'
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-cli php-mysql php-cgi php-curl php-json php-apcu php-gd php-xml php-mbstring php-gettext nfs-common geoip-bin
systemctl start apache2 && sleep 1

# 
chmod 644 '/var/log' && echo 'changed permissions on /var/log to 644'
(bash -c 'touch /var/log/auth.log' && sleep 1) && echo 'created /var/log/auth.log'
if [[ -f '/var/log/auth.log' ]]; then (chmod 644 '/var/log/auth.log' && echo 'changed permissions on /var/log/auth.log to 644'); fi

# set loglevel to verbose
echo 'setting LogLevel to VERBOSE'
sed -i -r 's/^#(SyslogFacility AUTH)/\1/g' '/etc/ssh/sshd_config' && echo 'SyslogFacility set to AUTH'
sed -i -r 's/^#(LogLevel) INFO/\1 VERBOSE/g' '/etc/ssh/sshd_config' && echo 'LogLevel set to VERBOSE'
systemctl restart sshd && sleep 1

# 
echo 'creating /var/webserver_log'
mkdir -p '/var/webserver_log' && echo 'created /var/webserver_log'
chmod 777 '/var/webserver_log' && echo 'changed permissions on /var/webserver_log to 777'

#
echo 'mounting /var/webserver_log'
mount 192.168.1.2:/var/webserver_monitor /var/webserver_log && echo 'mounted /var/webserver_log'

# 
echo 'creating /var/webserver_log/unauthorized.log'
(bash -c 'touch /var/webserver_log/unauthorized.log' && sleep 1) && echo 'created /var/webserver_log/unauthorized.log'
if [[ -f '/var/webserver_log/unauthorized.log' ]]; then (chmod 666 '/var/webserver_log/unauthorized.log' && echo 'changed permissions on /var/webserver_log/unauthorized.log to 666'); fi
