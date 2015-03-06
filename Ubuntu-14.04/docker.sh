#!/bin/bash
#
#

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

cat > /etc/apt/sources.list.d/docker.list << EOF
deb https://get.docker.com/ubuntu docker main
EOF

apt-get update
apt-get install -y lxc-docker
