#!/bin/bash

# get and install everything except drupal
echo 'installing packages...'
wget https://www.cs.wcupa.edu/lngo/data2/mysql-apt-config_0.8.17-1_all.deb -O /users/JM941935/mysql-apt-config_0.8.17-1_all.deb
dpkg -i '/users/JM941935/mysql-apt-config_0.8.17-1_all.deb'
apt-get update
apt-get install -y mysql-community-server acl apache2 php phpmyadmin libapache2-mod-php php-cli php-mysql php-cgi php-curl php-json php-apcu php-gd php-xml php-mbstring php-gettext 
systemctl start apache2 && sleep 1

# create password-less login
echo 'editing /root/.my.cnf...'
touch '/root/.my.cnf'
echo '[client]' >> '/root/.my.cnf'
echo 'user=root' >> '/root/.my.cnf'
echo 'password="123"' >> '/root/.my.cnf'
systemctl restart mysql && sleep 1

# copy index.html to userdir, create php test file
echo 'creating test files...'
mkdir '/users/JM941935/public_html'
cp '/var/www/html/index.html' '/users/JM941935/public_html/index.html'
bash -c 'touch /users/JM941935/public_html/info.php'
bash -c 'echo "<?php phpinfo();?>" >> "/users/JM941935/public_html/info.php"'

# enable apache modules
echo 'enabling modules...'
a2enmod userdir && sleep 1
a2enmod rewrite && sleep 1
a2enconf drupal && sleep 1
systemctl restart apache2 && sleep 1

# edit UserDir configuration file '/etc/apache2/mods-available/userdir.conf'
echo 'editing userdir config...'
sed -i -r 's/(<Directory) \/home\/\*\/public_html(>)/\1 \/users\/JM941935\/public_html\2/g' '/etc/apache2/mods-available/userdir.conf'

# edit main PHP configuration file (comment out last 5 lines)
echo 'editing php config...'
sed -i -r 's/(<IfModule mod_userdir\.c>)/#\1/g' '/etc/apache2/mods-enabled/php7.2.conf'
sed -i -r 's/(<Directory \/home\/\*\/public_html>)/#\1/g' '/etc/apache2/mods-enabled/php7.2.conf'
sed -i -r 's/(php_admin_flag engine Off)/#\1/g' '/etc/apache2/mods-enabled/php7.2.conf'
sed -i -r 's/(<\/Directory>)/#\1/g' '/etc/apache2/mods-enabled/php7.2.conf'
sed -i -r 's/(<\/IfModule>)/#\1/g' '/etc/apache2/mods-enabled/php7.2.conf'

# set variables for drupal install
MACHINE=$(hostname -f | awk -F\. '{print $1}')
DRUPAL="$MACHINE"
DRUPAL+="_drupal"

# get and move drupal
echo 'installing drupal...'
wget https://ftp.drupal.org/files/projects/drupal-8.7.4.tar.gz -O /users/JM941935/drupal-8.7.4.tar.gz
tar xzf '/users/JM941935/drupal-8.7.4.tar.gz'
mv '/users/JM941935/drupal-8.7.4' "/var/www/html/$DRUPAL"

# edit drupal.conf, settings.php, create /sites/default/files
echo 'editing drupal.conf...'
cp "/var/www/html/$DRUPAL/.htaccess" '/etc/apache2/conf-available/drupal.conf'
sed -i -r "s/# Apache\/PHP\/Drupal settings\:/<Directory \/var\/www\/html\/${DRUPAL}>/g" '/etc/apache2/conf-available/drupal.conf'
bash -c 'echo "</Directory>" >> "/etc/apache2/conf-available/drupal.conf"'
mkdir "/var/www/html/$DRUPAL/sites/default/files"
cp "/var/www/html/$DRUPAL/sites/default/default.settings.php" "/var/www/html/$DRUPAL/sites/default/settings.php"
chmod 777 "/var/www/html/$DRUPAL/sites/default/settings.php"

# set file ACL
echo 'setting acl permissions...'
setfacl -m g:www-data:rwx "/var/www/html/$DRUPAL/sites/default/files"
setfacl -m g:www-data:rw "/var/www/html/$DRUPAL/sites/default/settings.php"
setfacl -b "/var/www/html/$DRUPAL/sites/default/settings.php"

# start apache
echo 'restarting apache2...'
systemctl restart apache2 && sleep 1

# cleanup
echo 'cleaning up...'
rm '/users/JM941935/mysql-apt-config_0.8.17-1_all.deb'
rm '/users/JM941935/drupal-8.7.4.tar.gz'

echo '/etc/apache2/mods-available/userdir.conf'
echo '/etc/apache2/mods-enabled/php7.2.conf'
echo '/etc/apache2/conf-available/drupal.conf'

ls -l '/users/JM941935/public_html'
echo '/users/JM941935/public_html/info.php'

echo "/var/www/html/$DRUPAL"
echo "/var/www/html/$DRUPAL/sites/default/files"
echo "/var/www/html/$DRUPAL/sites/default/settings.php"

echo "$MACHINE.emulab.net"
echo "$MACHINE.emulab.net/~JM941935"
echo "$MACHINE.emulab.net/~JM941935/info.php"
echo "$MACHINE.emulab.net/phpmyadmin"
echo "$MACHINE.emulab.net/$DRUPAL"

# bash -c "sudo -H mysql -u root -e '<command>'"
echo 'mysql'
echo 'mysql> create database drupal;'
echo 'mysql> create user drupal@localhost identified by '123';'
echo 'mysql> grant all on drupal.* to drupal@localhost;'
echo 'mysql> quit'
