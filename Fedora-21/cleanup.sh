yum -y erase gtk2 libX11 hicolor-icon-theme avahi bitstream-vera-fonts
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso

# Remove traces of mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
rm /root/anaconda-ks.cfg
