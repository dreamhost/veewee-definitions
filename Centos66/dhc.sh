/usr/sbin/usermod -a -G wheel installer
/usr/bin/passwd -d root
cat >> /etc/chkconfig.d/cloud-init-local << EOF
# chkconfig: 2345 09 90
EOF
#/bin/yum -y update
/bin/rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
/usr/bin/yum -y install cloud-utils-growpart cloud-init syslinux-extlinux dracut-modules-growroot
/usr/bin/yum -y erase firewalld NetworkManager
/sbin/dracut --force
/bin/sed -i 's/timeout 5/timeout 1/' /etc/extlinux.conf
rm /boot/grub/grub.conf
cat >> /boot/grub/grub.conf << EOF
# grub.conf generated by anaconda
#
#boot=/dev/vda1
default=0
timeout=5
splashimage=(hd0,0)/boot/grub/splash.xpm.gz
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=5 serial console
hiddenmenu
title CentOS (2.6.32-504.el6.x86_64)
        root (hd0,0)
        kernel /boot/vmlinuz-2.6.32-504.el6.x86_64 ro root=/dev/vda1 rd_NO_LUKS console=tty0 console=ttyS0,115200n8 LANG=en_US.UTF-8 rd_NO_MD rd_NO_LVM SYSFONT=latarcyrheb-sun16 crashkernel=auto KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM 
        initrd /boot/initramfs-2.6.32-504.el6.x86_64.img
EOF

#/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
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
manage_resolv_conf: true


cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - resolv_conf
 - rsyslog
 - users-groups
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

resolv_conf:
  nameservers: ['8.8.4.4', '8.8.8.8']
  domain: nodes.dreamcompute.com
  options:
    rotate: true
    timeout: 1


system_info:
  default_user:
    name: dhc-user
    lock_passwd: true
    gecos: DreamCompute User
    groups: [wheel, adm]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel 
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: openssh-daemon

# vim:syntax=yaml
EOF
cat >> /etc/cloud/cloud.cfg.d/25_dhc.cfg << EOF
datasource_list: [ 'ConfigDrive' ]
disable_ec2_metadata: True
datasource:
  ConfigDrive:
      dsmode: local
EOF
cat >> /etc/cloud/cloud.cfg.d/99_cleanup.cfg << EOF
runcmd:
 - [ /usr/sbin/userdel, -r, installer ]
 - [ /bin/rm, -f, /etc/cloud/cloud.cfg.d/99_cleanup.cfg]
EOF

rm /var/log/anaconda*
