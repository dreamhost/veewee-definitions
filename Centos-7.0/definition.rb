require 'erb'
ssh_user = 'installer'
ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
parsed = ERB.new(File.read("ks.cfg.erb")).result(binding)
out = File.new('ks.cfg', 'w')
out.write(parsed)

Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '2048',
  :disk_size => '10140',
  :disk_format => 'raw',
  :hostiocache => 'off',
  :os_type_id => 'Centos_64',
  :iso_file => "CentOS-7.0-1406-x86_64-Minimal.iso",
  :iso_src => "http://ftp.osuosl.org/pub/centos/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-Minimal.iso",
  :iso_md5 => "e3afe3f1121d69c40cc23f0bafa05e5d",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => 10000,
  :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => ssh_user,
  :ssh_password => ssh_password,
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [
    "base.sh",
    "dhc.sh",
#    "chef.sh",
#    "puppet.sh",
#    "vagrant.sh",
#    "virtualbox.sh",
    #"vmfusion.sh",
    "cleanup.sh",
    "zerodisk.sh"
  ],
  :postinstall_timeout => 10000
})
