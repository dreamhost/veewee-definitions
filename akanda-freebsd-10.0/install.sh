#!/bin/sh -x

sleep 10
# Enable required services
cat >> /etc/rc.conf << EOT
hostname="${NAME}"
ifconfig_vtnet0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
cat >> /boot/loader.conf << EOT
vm.kmem_size="200M"
vm.kmem_size_max="200M"
vfs.zfs.arc_max="40M"
vfs.zfs.vdev.cache.size="5M"
virtio_load="YES"
virtio_pci_load="YES"
virtio_blk_load="YES"
if_vtnet_load="YES"
virtio_balloon_load="YES"
EOT

# Set up user accounts
zfs create tank/root/home
zfs create tank/root/home/vagrant
echo "vagrant" | pw -V /etc useradd vagrant -h 0 -s csh -G wheel -d /home/vagrant -c "Vagrant User"

chown 1001:1001 /home/vagrant

mkdir -p /usr/local/etc

cat > /usr/local/etc/pkg.conf << EOF
# System-wide configuration file for pkg(8)
# For more information on the file format and
# options please refer to the pkg.conf(5) man page

# Configuration options
PKG_DBDIR          : /var/db/pkg
PKG_CACHEDIR       : /var/cache/pkg
PORTSDIR           : /usr/ports
PUBKEY             : /etc/ssl/pkg.conf
HANDLE_RC_SCRIPTS  : YES
ASSUME_ALWAYS_YES  : YES
SYSLOG             : YES
SHLIBS             : YES
AUTODEPS           : YES
PORTAUDIT_SITE     : http://portaudit.FreeBSD.org/auditfile.tbz
PKG_PLUGINS_DIR    : /usr/local/lib/pkg/plugins
PKG_ENABLE_PLUGINS : NO
#PLUGINS            : [commands/mystat]
REPO_AUTOUPDATE    : YES
ALIAS              : {
  all-depends: query %dn-%dv,
  annotations: info -A,
  build-depends: info -qd,
  download: fetch,
  iinfo: info -i -g -x,
  isearch: search -i -g -x,
  leaf: query -e "%a == 0" "%n-%v",
  leaf: query -e "%a == 0" "%n-%v",
  list: info -ql,
  origin: info -qo,
  provided-depends: info -qb,
  raw: info -R,
  required-depends: info -qr,
  shared-depends: info -qB,
  show: info -f -k,
  size: info -sq,
}
EOF

ASSUME_ALWAYS_YES=1 pkg bootstrap
pkg install -y bash
chsh -s /usr/local/bin/bash root

# Reboot
reboot

