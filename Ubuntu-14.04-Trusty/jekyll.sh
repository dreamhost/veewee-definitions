#!/bin/bash
#
# install jekyll https://github.com/jekyll/jekyll

apt-get -y install ruby ruby-dev git
gem install jekyll

cat > /etc/motd << EOF
Basic jekyll usage

Pick a theme here http://jekyllthemes.org/
# git clone https://github.com/swcool/landing-page-theme.git
# cd landing-page-theme

Run a development server on port 8080
# jekyll serve -H 0.0.0.0 -P 8080

Access your server in a browser: http://your_ip_address:8080
EOF
