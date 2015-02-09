#!/bin/bash

export MYSQL_PASSWORD=""
echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.5 mysql-server/root_password seen true
mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.5 mysql-server/root_password_again seen true" | debconf-set-selections 

DEBIAN_FRONTEND=noninteractive apt-get update || exit
DEBIAN_FRONTEND=noninteractive apt-get -y install nginx mysql-server php5-fpm php5-mysql php5-gd unzip || exit

curl -sL -o /tmp/concrete5.zip http://www.concrete5.org/download_file/-/view/74619/ && unzip /tmp/concrete5.zip -d /var/www
mv /var/www/concrete5* /var/www/concrete5 && chown www-data.www-data /var/www -R

mysqladmin create concrete5

cat > /etc/nginx/conf.d/fastcgi.conf << 'EOF'
fastcgi_cache_path      /var/lib/nginx/cache levels=1:2
keys_zone=c5:10m
inactive=5m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";
fastcgi_cache_use_stale error timeout invalid_header http_500;
EOF

cat > /etc/nginx/sites-available/concrete5 << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www/concrete5;
    index index.php index.html index.htm;

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /var/www/concrete5;
    }

    location ~ /\. { deny all; access_log off; log_not_found off; }
 
    location ~* \.(ico|css|js|gif|jpe?g|png)(\?[0-9]+)?$ {
        expires max;
        log_not_found off;
    }
 
    set $skip_cache 0;
 
    # POST requests and urls with a query string should always go to PHP
    if ($request_method = POST) {
        set $skip_cache 1;
    }
    if ($query_string != "") {
        set $skip_cache 1;
    }
    if ($http_cookie ~ "CONCRETE5") {
        set $skip_cache 1;
    }
 
    location / {
        try_files $uri $uri/ /index.php$uri;
        if (!-f $request_filename){
            set $rule_0 1$rule_0;
        }
        if (!-d $request_filename){
            set $rule_0 2$rule_0;
        }
        if ($rule_0 = "21"){
            rewrite ^/(.*)$ /index.php/$1 last;
        }
    }
 
    location ~ \.php {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        fastcgi_cache c5;
        fastcgi_cache_valid   any      1m;
    }

}
EOF

rm -fv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/concrete5 /etc/nginx/sites-enabled/concrete5

cat > /etc/rc.first-boot << EOF
#!/bin/bash
mysql -e "GRANT ALL PRIVILEGES ON concrete5.* TO 'concrete5'@'localhost' IDENTIFIED BY 'concrete5';"
EOF
chmod 755 /etc/rc.first-boot
