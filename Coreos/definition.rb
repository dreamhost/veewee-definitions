require 'erb'
ssh_user = 'installer'
ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
parsed = ERB.new(File.read("ks.cfg.erb")).result(binding)
out = File.new('ks.cfg', 'w')
out.write(parsed)
out.close

Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '1024',
  :disk_size => '10140',
  :disk_format => 'raw',
  :hostiocache => 'off',
  :hwvirtext => 'on',
  :os_type_id => 'Linux',
  :iso_file => "coreos_production_openstack_image.img",
  :iso_src => "http://storage.core-os.net/coreos/amd64-usr/beta/coreos_production_openstack_image.img.bz2",
  :iso_sha256 => "312838bd094224a997e6ff59dc313100bd34eee3",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [ 'i<Tab> linux text net.ifnames=0 biosdevname=0 <Enter><Enter>' ],
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
    #"ruby.sh",
    #"chef.sh",
    #"puppet.sh",
    #"vagrant.sh",
    #"virtualbox.sh",
    #"vmfusion.sh",
    "dhc.sh",
    "cleanup.sh",
    "zerodisk.sh"
  ],
  :postinstall_timeout => 10000
})
