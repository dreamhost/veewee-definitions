# Clean up
apt-get -y remove linux-headers-$(uname -r) build-essential isc-dhcp-client nfs-common rpcbind exim4
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# no more postinstall scipts after this
userdel -f -r installer
rm /etc/sudoers.d/installer
