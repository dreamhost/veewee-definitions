#!/bin/bash
#
#
echo "Installing gitlab omnibus"
URL="https://downloads-packages.s3.amazonaws.com/ubuntu-14.04/gitlab_7.7.2-omnibus.5.4.2.ci-1_amd64.deb"
wget -O /tmp/gitlab.deb $URL
dpkg -i /tmp/gitlab.deb && rm /tmp/gitlab.deb

# Inital gitlab setup
gitlab-ctl reconfigure

# Clean things we should regenerate
# on first boot for each app install
rm /etc/gitlab/gitlab-secrets.json


cat > /tmp/first-boot.sh << EOF
#!/bin/bash
#
#
gitlab-ctl reconfigure
EOF

chmod 755 /tmp/first-boot.sh
