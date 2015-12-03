require 'erb'
#require 'Time'
ssh_user = 'installer'

now = Time.now
if File.file?('pass.cache') and now - File.stat('pass.cache').mtime < 86400 then
  puts('using cached password')
  pw = File.open('pass.cache')
  ssh_password = pw.gets
else
  puts('generating new password')
  ssh_password = Array.new(24){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
  out = File.new('pass.cache', 'w')
  out.write(ssh_password)
  out.close
end

parsed = ERB.new(File.read("preseed.cfg.erb")).result(binding)
out = File.new('preseed.cfg', 'w')
out.write(parsed)
out.close

if !File.file?('installer-key.pub') then
  system "ssh-keygen -t rsa -N '' -f installer-key"
end
sk = File.open('installer-key.pub')
ssh_key_contents = sk.gets
ssh_script = ERB.new(File.read("sshkey.sh.erb")).result(binding)
out = File.new('sshkey.sh', 'w')
out.write(ssh_script)
out.close

Veewee::Definition.declare({
  :cpu_count => '1',
  :memory_size=> '256',
  :disk_size => '5000', :disk_format => 'raw', :hostiocache => 'off',
  :os_type_id => 'Debian_64',
  :iso_file => "debian-8.1.0-amd64-netinst.iso",
  :iso_src => "http://cdimage.debian.org/debian-cd/8.1.0/amd64/iso-cd/debian-8.1.0-amd64-netinst.iso",
  :iso_md5 => "1a311f9afb68d6365211b13b4342c40b",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
     '<Esc>',
     'install ',
     'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
     'debian-installer=en_US ',
     'auto ',
     'locale=en_US ',
     'kbd-chooser/method=us ',
     'netcfg/get_hostname=%NAME% ',
     'fb=false ',
     'debconf/frontend=noninteractive ',
     'console-setup/ask_detect=false ',
     'console-keymaps-at/keymap=us ',
     'keyboard-configuration/xkb-keymap=us ',
     '<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => ssh_user,
  :ssh_password => ssh_password,
  :ssh_key => "installer-key",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S bash '%f'",
  :shutdown_cmd => "halt -p",
  :postinstall_files => [
    "base.sh",
    "dhc.sh",
    "sshkey.sh",
    "cleanup.sh",
    "zerodisk.sh"
  ],
  :postinstall_timeout => "10000"
})
