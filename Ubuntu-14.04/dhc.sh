/bin/echo "cloud-init cloud-init/datasources string ConfigDrive" | /usr/bin/debconf-set-selections        
#/usr/sbin/useradd -s /bin/bash -m dhc-user
#echo "dhc-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/dhc-user
#chmod 440 /etc/sudoers.d/dhc-user
/usr/bin/apt-get -y install cloud-init cloud-initramfs-rescuevol cloud-initramfs-growroot python-setuptools
rm /etc/network/if-up.d/ntpdate
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
cat > /etc/cloud/cloud.cfg << EOF
users:
 - default
disable_root: 1
ssh_pwauth:   0

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - rsyslog
 - users-groups
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: dhc-user
    lock_passwd: true
    gecos: DreamCompute User
    groups: [adm, sudo]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: ubuntu
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: ssh

# vim:syntax=yaml
EOF
cat >> /etc/cloud/cloud.cfg.d/15_hosts.cfg << EOF
manage_etc_hosts: template
EOF
cat >> /etc/cloud/cloud.cfg.d/25_dhc.cfg << EOF
datasource_list: [ 'ConfigDrive', 'Ec2' ]
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
 - [ /bin/sed, -i, '/\/tmp\/.*. vfat .*./d', /etc/mtab ]
 - [ /usr/sbin/userdel, -r, installer ]
 - [ /bin/rm, -f, /etc/cloud/cloud.cfg.d/99_cleanup.cfg]

EOF

cat >> /etc/resolvconf/resolv.conf.d/base << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
search nodes.dreamcompute.net
EOF

## Explicitly mounting the config drive seems to work around a bug in mountall
#mkdir /mnt/config-2
#echo '/dev/sr0 /mnt/config-2 iso9660 defaults 0 0' >> /etc/fstab
