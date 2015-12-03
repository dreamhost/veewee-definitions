dnf -y erase gtk2 libX11 hicolor-icon-theme avahi bitstream-vera-fonts
dnf -y clean all
rm -rf VBoxGuestAdditions_*.iso

#cleanup dnf fastest mirror cache
rm -f /var/cache/dnf/timedhosts.txt

# Remove traces of mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
rm /root/anaconda-ks.cfg

# remove auto-created /etc/hosts entry
echo "cleaning out /etc/hosts entries"
sed -i 's/127.0.1.1.*//' /etc/hosts
