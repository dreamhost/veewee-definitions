#!/bin/sh -e

cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# custom rc.local
#

if [ -f /etc/rc.first-boot ];
then
        /etc/rc.first-boot && rm /etc/rc.first-boot
fi
exit 0
EOF

chmod 755 /etc/rc.local
