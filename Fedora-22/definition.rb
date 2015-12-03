require 'erb'
ssh_user = 'installer'
ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
parsed = ERB.new(File.read("ks.cfg.erb")).result(binding)
out = File.new('ks.cfg', 'w')
out.write(parsed)
out.close

Veewee::Session.declare({
  # Minimum RAM requirement for installation is 512MB.
  :cpu_count => '1',
  :memory_size=> '1024',
  :disk_size => '10140',
  :disk_format => 'raw',
  :hostiocache => 'off',
  :hwvirtext => 'on',
  :os_type_id => 'Fedora_64',
  :iso_file => "Fedora-Server-DVD-x86_64-22.iso",
  :iso_src => "http://mirror.sfo12.us.leaseweb.net/fedora/linux/releases/22/Server/x86_64/iso/Fedora-Server-DVD-x86_64-22.iso",
  :iso_sha256 => "b2acfa7c7c6b5d2f51d3337600c2e52eeaa1a1084991181c28ca30343e52e0df",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [ 'i<Tab> linux text net.ifnames=0 biosdevname=0 ks=http://%IP%:%PORT%/ks.cfg<Enter><Enter>' ],
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
