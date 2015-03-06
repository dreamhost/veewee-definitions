#!/bin/bash

export MYSQL_PASSWORD=""
echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.5 mysql-server/root_password seen true
mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.5 mysql-server/root_password_again seen true" | debconf-set-selections 

DEBIAN_FRONTEND=noninteractive apt-get update || exit
DEBIAN_FRONTEND=noninteractive apt-get -y install nginx mysql-server php5-fpm php5-mysql || exit


cat > /etc/nginx/sites-available/php << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

rm -fv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/php /etc/nginx/sites-enabled/php

cat > /usr/share/nginx/html/info.php << 'EOF'
<?php
        phpinfo();
?>
EOF

cat > /etc/rc.first-boot << EOF
#!/bin/bash
EOF
chmod 755 /etc/rc.first-boot
