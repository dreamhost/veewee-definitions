require 'erb'
ssh_user = 'installer'
ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
parsed = ERB.new(File.read("ks.cfg.erb")).result(binding)
out = File.new('ks.cfg', 'w')
out.write(parsed)

Veewee::Session.declare({
  # Minimum RAM requirement for installation is 512MB.
  :cpu_count => '1',
  :memory_size=> '1024',
  :disk_size => '10140',
  :disk_format => 'raw',
  :hostiocache => 'off',
  :hwvirtext => 'on',
  :os_type_id => 'Fedora_64',
  :iso_file => "Fedora-Server-DVD-x86_64-21.iso",
  :iso_src => "http://download.fedoraproject.org/pub/fedora/linux/releases/21/Server/x86_64/iso/Fedora-Server-DVD-x86_64-21.iso",
  :iso_sha256 => "a6a2e83bb409d6b8ee3072ad07faac0a54d79c9ecbe3a40af91b773e2d843d8e",
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
    "zerodisk.sh",
    "reboot.sh"
  ],
  :postinstall_timeout => 10000
})
