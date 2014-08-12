/bin/echo "cloud-init cloud-init/datasources string ConfigDrive, Ec2" | /usr/bin/debconf-set-selections        
/usr/sbin/useradd -s /bin/bash -m dhc-user
echo "dhc-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/dhc-user
chmod 440 /etc/sudoers.d/dhc-user
/usr/bin/apt-get -y install cloud-init cloud-initramfs-rescuevol cloud-initramfs-growroot linux-image-3.11.0-20-generic python-setuptools
rm /etc/default/grub
cat >> /etc/default/grub << EOF
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=Debian
GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0 rootwait"
GRUB_CMDLINE_LINUX=""
GRUB_RECORDFAIL_TIMEOUT=0

# Uncomment to disable graphical terminal (grub-pc only)
GRUB_TERMINAL=console
EOF

/usr/sbin/update-grub
cp /etc/cloud/templates/hosts.debian.tmpl /etc/cloud/templates/hosts.ubuntu.tmpl
cat >> /etc/apt/preferences.d/99dhc << EOF
APT::Default-Release "precise";
EOF

cat >> /etc/apt/sources.list.d/trusty.list << EOF
deb http://archive.ubuntu.com/ubuntu trusty main
EOF

/bin/sed -i 's/^user: ubuntu/user: dhc-user/g' /etc/cloud/cloud.cfg
cat >> /etc/cloud/cloud.cfg.d/15_hosts.cfg << EOF
manage_etc_hosts: template
EOF
cat >> /etc/cloud/cloud.cfg.d/25_dhc.cfg << EOF
datasource_list: [ 'ConfigDrive' ]
datasource:
  ConfigDrive:
      dsmode: local

growpart:
  mode: auto
  devices: ['/']

resize_rootfs: True

EOF
cat >> /etc/cloud/cloud.cfg.d/99_cleanup.cfg << EOF

runcmd:
 - [ /usr/sbin/userdel, -r, installer ]
 - [ /bin/rm, -f, /etc/cloud/cloud.cfg.d/99_cleanup.cfg]

EOF

## Explicitly mounting the config drive seems to work around a bug in mountall
mkdir /mnt/config-2
echo '/dev/sr0 /mnt/config-2 iso9660 defaults 0 0' >> /etc/fstab
