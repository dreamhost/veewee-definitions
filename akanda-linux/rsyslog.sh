cat <<EOF > /etc/rsyslog.d/49-remote.conf
*.* @[fdca:3ba5:a17a:acda::1]:514
EOF
