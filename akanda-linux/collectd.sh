apt-get -y install collectd
cat <<EOF > /etc/collectd/collectd.conf
FQDNLookup True
Interval 10
Timeout 2
ReadThreads 5
LoadPlugin cpu
LoadPlugin interface
LoadPLugin network

<Plugin network>
        Server "fdca:3ba5:a17a:acda::1"
</Plugin>

EOF
