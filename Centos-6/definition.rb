require 'erb'
ssh_user = 'installer'
ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
parsed = ERB.new(File.read("ks.cfg.erb")).result(binding)
out = File.new('ks.cfg', 'w')
out.write(parsed)
out.close

Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '2048',
  :disk_size => '10140',
  :disk_format => 'raw',
  :hostiocache => 'off',
  :os_type_id => 'RedHat6_64',
  :iso_file => "CentOS-6.7-x86_64-minimal.iso",
  :iso_src => "http://repos.mia.quadranet.com/centos/6.7/isos/x86_64/CentOS-6.7-x86_64-minimal.iso",
  :iso_md5 => "9381a24b8bee2fed0c26896141a64b69",
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
    "zerodisk.sh",
    "reboot.sh" # required to get growpart to work
  ],
  :postinstall_timeout => 10000
})
