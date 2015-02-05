#!/bin/bash
export MYSQL_PASSWORD=""
echo "mysql-server-5.5 mysql-server/root_password password ${MYSQL_PASSWORD}
mysql-server-5.5 mysql-server/root_password seen true
mysql-server-5.5 mysql-server/root_password_again password ${MYSQL_PASSWORD}
mysql-server-5.5 mysql-server/root_password_again seen true
" | debconf-set-selections

curl -L http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_14.04/Release.key |apt-key add -
sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud.list"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install owncloud
