#!/bin/bash

# remove man-db because its slow
echo 'removing man-db...'
apt-get remove -y --purge man-db
apt-get install debconf-utils

# add selections to debconf database
echo 'adding selections to debconf database...'
bash -c 'echo "mysql-community-server mysql-community-server/re-root-pass password 123" | debconf-set-selections'
bash -c 'echo "mysql-community-server mysql-community-server/remove-data-dir boolean false" | debconf-set-selections'
bash -c 'echo "mysql-community-server mysql-community-server/root-pass password 123" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/app-password-confirm password 123" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/mysql/admin-pass password 123" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/mysql/app-pass password 123" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/password-confirm password 123" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/reconfigure-webserver select apache2" | debconf-set-selections'
bash -c 'echo "phpmyadmin phpmyadmin/setup-password password 123" | debconf-set-selections'

# 
wget https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/lamp.sh -O /users/JM941935/lamp.sh
