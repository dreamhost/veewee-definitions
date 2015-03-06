#!/bin/bash
#
# install golang


curl -sL -o /tmp/golang.tar.gz https://storage.googleapis.com/golang/go1.4.1.linux-amd64.tar.gz
tar zxvf /tmp/golang.tar.gz -C /opt && rm /tmp/golang.tar.gz

cat > /etc/profile.d/go.sh << 'EOF'
export GOPATH=/opt/gopkg
export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
