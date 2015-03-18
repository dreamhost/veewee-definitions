#!/bin/bash
. $HOME/.veewee_params

DEPENDS="git"
apt-get -y install $DEPENDS

# install chefdk
curl -L -o /tmp/chefdk.deb http://mirrors.dreamcompute.com/chef/chefdk_0.4.0-1_amd64.deb
dpkg -i /tmp/chefdk.deb

mkdir -p /tmp/chef/cookbooks

cat > /tmp/chef/solo.rb << 'EOF'
file_cache_path    "/var/chef/cache"
file_backup_path   "/var/chef/backup"
cookbook_path ["/tmp/chef/cookbooks","~/.berkshelf/cookbooks"]
role_path []
log_level :info
verbose_logging    true
EOF

git clone $COOKBOOK_REPO /tmp/chef/cookbooks/dhcapps
(cd /tmp/chef/cookbooks/dhcapps && berks install)

# print environment
chef-solo -c /tmp/chef/solo.rb -o $COOKBOOK_RUNLIST

# remove chef
apt-get -y remove chefdk
dpkg --purge chefdk
