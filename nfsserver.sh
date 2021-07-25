#!/bin/bash

# 
echo 'adding selections to debconf database...'
export DEBIAN_FRONTEND="noninteractive"
# bash -c 'echo "ldap-auth-config ldap-auth-config/rootbindpw password 123" | debconf-set-selections'
# bash -c 'echo "ldap-auth-config ldap-auth-config/bindpw password 123" | debconf-set-selections'
# bash -c 'echo "ldap-auth-config ldap-auth-config/override boolean true" | debconf-set-selections'
# bash -c 'echo "ldap-auth-config ldap-auth-config/pam_password select md5" | debconf-set-selections'
# bash -c 'echo "ldap-auth-config ldap-auth-config/move-to-debconf boolean true" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/rootbinddn string cn=admin,dc=emulab,dc=net" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/dblogin boolean false" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/dbrootlogin boolean true" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://192.168.1.1" | debconf-set-selections'
bash -c 'echo "ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=emulab,dc=net" | debconf-set-selections'

# 
echo 'installing software...'
sudo apt-get remove -y --purge man-db
sudo apt-get update
sudo apt install -y libnss-ldap libpam-ldap ldap-utils nfs-kernel-server
