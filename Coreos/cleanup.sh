yum -y erase gtk2 libX11 hicolor-icon-theme avahi bitstream-vera-fonts
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso

# Remove traces of mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0

# remove auto-created /etc/hosts entry
echo "cleaning out /etc/hosts entries"
sed -i 's/127.0.1.1.*//' /etc/hosts
