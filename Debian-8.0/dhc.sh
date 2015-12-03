/bin/echo "cloud-init cloud-init/datasources string ConfigDrive" | /usr/bin/debconf-set-selections        
/bin/echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/wheezy_backports.list
/usr/bin/passwd -d root
/usr/bin/apt-get update
APT_LISTCHANGES_FRONTEND=none DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -y install cloud-init cloud-initramfs-growroot
APT_LISTCHANGES_FRONTEND=none DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -y dist-upgrade
APT_LISTCHANGES_FRONTEND=none DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -y -t wheezy-backports install linux-image-amd64
cat > /etc/default/grub << EOF
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=Debian
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200n8"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF
/usr/sbin/update-grub
cat > /etc/cloud/cloud.cfg << EOF
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
   - default

# If this is set, 'root' will not be able to ssh in and they 
# will get a message to login instead as the above $user (ubuntu)
disable_root: true
ssh_pwauth:   1

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# Example datasource config
# datasource: 
#    Ec2: 
#      metadata_urls: [ 'blah.com' ]
#      timeout: 5 # (defaults to 50 seconds)
#      max_wait: 10 # (defaults to 120 seconds)

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
 - emit_upstart
 - mounts
 - ssh-import-id
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - package-update-upgrade-install
 - landscape
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd
 - byobu

# The modules that run in the 'final' stage
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
 - power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
   # This will affect which distro class gets used
   distro: debian
   # Default user name + that default users groups (if added/used)
   default_user:
     name: dhc-user
     sudo: ALL=(ALL) NOPASSWD:ALL
     shell: /bin/bash
     lock_passwd: True
     gecos: DreamCompute User
     groups: [adm, audio, cdrom, dialout, floppy, video, plugdev, dip]
   # Other config here will be given to the distro class and/or path classes
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
      upstart_dir: /etc/init/
   package_mirrors:
     - arches: [default]
       failsafe:
         primary: http://ftp.debian.org/debian
EOF

cat >> /etc/cloud/cloud.cfg.d/15_hosts.cfg << EOF
manage_etc_hosts: template
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
