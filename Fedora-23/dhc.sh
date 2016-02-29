/usr/sbin/usermod -a -G wheel installer
/bin/passwd -d root
#/bin/yum -y update
/bin/dnf -y install cloud-utils-growpart cloud-init
/bin/dnf -y erase firewalld NetworkManager
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
cat > /etc/cloud/cloud.cfg.d/05_logging.cfg << EOF
## This yaml formated config file handles setting
## logger information.  The values that are necessary to be set
## are seen at the bottom.  The top '_log' are only used to remove
## redundency in a syslog and fallback-to-file case.
##
## The 'log_cfgs' entry defines a list of logger configs
## Each entry in the list is tried, and the first one that
## works is used.  If a log_cfg list entry is an array, it will
## be joined with '\n'.
_log:
 - &log_base |
   [loggers]
   keys=root,cloudinit

   [handlers]
   keys=consoleHandler,cloudLogHandler

   [formatters]
   keys=simpleFormatter,arg0Formatter

   [logger_root]
   level=DEBUG
   handlers=consoleHandler,cloudLogHandler

   [logger_cloudinit]
   level=DEBUG
   qualname=cloudinit
   handlers=
   propagate=1

   [handler_consoleHandler]
   class=StreamHandler
   level=INFO
   formatter=arg0Formatter
   args=(sys.stderr,)

   [formatter_arg0Formatter]
   format=%(asctime)s - %(filename)s[%(levelname)s]: %(message)s

   [formatter_simpleFormatter]
   format=[CLOUDINIT] %(filename)s[%(levelname)s]: %(message)s
 - &log_file |
   [handler_cloudLogHandler]
   class=FileHandler
   level=DEBUG
   formatter=arg0Formatter
   args=('/var/log/cloud-init.log',)
 - &log_syslog |
   [handler_cloudLogHandler]
   class=handlers.SysLogHandler
   level=DEBUG
   formatter=simpleFormatter
   args=("/dev/log", handlers.SysLogHandler.LOG_USER)

log_cfgs:
# These will be joined into a string that defines the configuration
 - [ *log_base, *log_syslog ]
# These will be joined into a string that defines the configuration
 - [ *log_base, *log_file ]
# A file path can also be used
# - /etc/log.conf

# this tells cloud-init to redirect its stdout and stderr to
# 'tee -a /var/log/cloud-init-output.log' so the user can see output
# there without needing to look on the console.
output: {all: '| tee -a /var/log/cloud-init-output.log'}
EOF
cat > /usr/lib/systemd/system/cloud-init.service << EOF
[Unit]
Description=Initial cloud-init job (metadata service crawler)
After=local-fs.target network.target cloud-init-local.service
Requires=network.target
Wants=local-fs.target cloud-init-local.service
Before=plymouth-quit.service

[Service]
Type=oneshot
ExecStart=/usr/bin/cloud-init init
RemainAfterExit=yes
TimeoutSec=0

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF
cat > /usr/lib/systemd/system/cloud-final.service << EOF
[Unit]
Description=Execute cloud user/final scripts
After=network.target syslog.target cloud-config.service rc-local.service
Requires=cloud-config.target
Wants=network.target
Before=plymouth-quit.service

[Service]
Type=oneshot
ExecStart=/usr/bin/cloud-init modules --mode=final
RemainAfterExit=yes
TimeoutSec=0

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF
