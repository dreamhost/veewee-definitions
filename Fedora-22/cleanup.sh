dnf -y erase gtk2 libX11 hicolor-icon-theme avahi bitstream-vera-fonts
dnf -y clean all
rm -rf VBoxGuestAdditions_*.iso

#cleanup dnf fastest mirror cache
rm -f /var/cache/dnf/timedhosts.txt

# Remove traces of mac address from network configuration
rm /root/anaconda-ks.cfg
# Also cleanup ifcfg-eth0, because cloudinit does not play nice with it already
# being defined when cloudinit is trying to set static IPs
rm /etc/sysconfig/network-scripts/ifcfg-eth0

# remove auto-created /etc/hosts entry
echo "cleaning out /etc/hosts entries"
sed -i 's/127.0.1.1.*//' /etc/hosts
