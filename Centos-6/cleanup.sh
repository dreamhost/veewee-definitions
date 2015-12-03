yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all
rm -rf /etc/yum.repos.d/{puppetlabs,epel}.repo
rm -rf VBoxGuestAdditions_*.iso

#cleanup yum fastest mirror cache
rm -f /var/cache/yum/timedhosts.txt

# Remove traces of mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
rm /etc/udev/rules.d/70-persistent-net.rules

# remove auto-created /etc/hosts entry
echo "cleaning out /etc/hosts entries"
sed -i 's/127.0.1.1.*//' /etc/hosts
