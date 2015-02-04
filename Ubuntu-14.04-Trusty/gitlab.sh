#!/bin/bash
#
#
echo "Installing gitlab omnibus"
wget https://downloads-packages.s3.amazonaws.com/ubuntu-14.04/gitlab_7.7.2-omnibus.5.4.2.ci-1_amd64.deb
dpkg -i gitlab_7.7.2-omnibus.5.4.2.ci-1_amd64.deb
