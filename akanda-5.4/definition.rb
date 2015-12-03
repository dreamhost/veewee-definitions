require 'erb'

if File.file?('key.sh')
    File.delete('key.sh')
end

key_file = File.new('key.sh', 'w')

if File.file?('router.key')
    ssh_key = File.open('router.key').read().chomp!
    parsed = ERB.new(File.read("key.sh.erb")).result(binding)
    key_file.write(parsed)
    key_file.close
end

Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256',
  :disk_size => '1024', :disk_format => 'raw', :hostiocache => 'off',
  :os_type_id => 'OpenBSD_64',
  :iso_file => "openbsd54_64.iso",
  :iso_src => "http://ftp3.usa.openbsd.org/pub/OpenBSD/5.4/amd64/install54.iso",
  :iso_sha256 => "9b59c031a0a2c127f824449294be9a88a05624ccf179b0d1b44d714f13b68448",
  :iso_download_timeout => "1000",
  :boot_wait => "40", :boot_cmd_sequence => [
# I - install
   'I<Enter>',
# set the keyboard
   'us<Enter>',
# set the hostname
   'OpenBSD54-x64<Enter>',
# Which nic to config ? [em0]
   '<Enter>',
# do you want dhcp ? [dhcp]
   '<Enter>',
   '<Wait>'*5,
# IPV6 for em0 ? [none]
   'none<Enter>',
# Which other nic do you wish to configure [done]
   'done<Enter>',
# Pw for root account
   'vagrant<Enter>',
   'vagrant<Enter>',
# Start sshd by default ? [yes]
   'yes<Enter>',
# Start ntpd by default ? [yes]
   'no<Enter>',
# Do you want the X window system [yes]
   'no<Enter>',
# Change default console to com0?
   'no<Enter>',
# Setup a user ?
   'no<Enter>',
# Do you want to disable sshd for root ? [yes]
   'no<Enter>',
# What timezone are you in ?
   'UTC<Enter>',
# Available disks [sd0]
   '<Enter>',
   '<Wait>'*2,
# Use DUIDs rather than device names in fstab ? [yes]
   '<Enter>',
   '<Wait>'*2,
# Use (W)whole disk or (E)edit MBR ? [whole]
   'W<Enter>',
   '<Wait>'*2,
# Use (A)auto layout ... ? [a]
   'A<Enter>',
   '<Wait>'*70,
# location of the sets [cd]
   'cd<Enter>',
# Available cd-roms : cd0
   '<Enter>',
# Pathname to sets ? [5.4/amd64]
   '<Enter>',
# Remove games and X
   '-game54.tgz<Enter>',
   '-xbase54.tgz<Enter>',
   '-xetc54.tgz<Enter>',
   '-xshare54.tgz<Enter>',
   '-xfont54.tgz<Enter>',
   '-xserv54.tgz<Enter>',
   'done<Enter>',
   '<Wait>'*110,
# Done installing ?
   'done<Enter>',
   '<Wait>'*6,
# Time appears wrong. Set to ...? [yes]
   'yes<Enter><Wait>',
   '<Wait>'*6,
   'reboot<Enter>',
   '<Wait>'*6
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "/sbin/halt -p",
  :postinstall_files => [
    "base.sh",
    "key.sh",
    "create-akanda-raw-image.sh",
    "cleanup.sh"
  ],
  :postinstall_timeout => "10000"
})
