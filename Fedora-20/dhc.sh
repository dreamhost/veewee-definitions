/usr/sbin/usermod -a -G wheel installer
/bin/passwd -d root
#/bin/yum -y update
/bin/yum -y install cloud-utils-growpart cloud-init
/bin/yum -y erase firewalld NetworkManager
/bin/sed -i 's/timeout 5/timeout 1/' /etc/extlinux.conf
#rm /etc/default/grub
#echo >> /etc/default/grub << EOF
#GRUB_TIMEOUT=2
#GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
#GRUB_DEFAULT=saved
#GRUB_DISABLE_SUBMENU=true
#GRUB_TERMINAL_OUTPUT="ttyS0"
#GRUB_TERMINAL="serial"
#GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
#GRUB_CMDLINE_LINUX="norhgb biosdevname=0 console=tty0 console=ttyS0,115200n8 net.ifnames=0 $([ -x /usr/sbin/rhcrashkernel-param ] && /usr/sbin/rhcrashkernel-param || :)"
#GRUB_DISABLE_RECOVERY="true"
#EOF

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

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
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

system_info:
  default_user:
    name: dhc-user
    lock_passwd: true
    gecos: DreamCompute User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: fedora
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
EOF
cat >> /etc/cloud/cloud.cfg.d/25_dhc.cfg << EOF
datasource_list: [ 'ConfigDrive' ]
datasource:
  ConfigDrive:
    dsmode: local
EOF
cat >> /etc/cloud/cloud.cfg.d/99_cleanup.cfg << EOF
runcmd:
 - [ /usr/sbin/userdel, -r, installer ]
 - [ /bin/rm, -f, /etc/cloud/cloud.cfg.d/99_cleanup.cfg]
EOF
