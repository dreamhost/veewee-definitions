#!/bin/sh -e

cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# custom rc.local
#

if [ -f /tmp/first-boot.sh ];
then
        /tmp/first-boot.sh && rm /tmp/first-boot.sh
fi
exit 0
EOF

chmod 755 /etc/rc.local
