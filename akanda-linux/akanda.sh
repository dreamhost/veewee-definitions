#!/bin/sh
apt-get -y install git
git clone https://github.com/dreamhost/akanda-appliance.git /tmp/akanda-appliance
sh /tmp/akanda-appliance/scripts/create-akanda-raw-image.sh
