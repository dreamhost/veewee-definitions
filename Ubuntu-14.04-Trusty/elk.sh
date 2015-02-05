#!/bin/bash

curl -L https://packages.elasticsearch.org/GPG-KEY-elasticsearch |apt-key add -
add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main"
add-apt-repository "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main"

apt-get update && apt-get -y install elasticsearch logstash
update-rc.d elasticsearch defaults 95 10


cat > /etc/logstash/conf.d/01-input.conf << EOF
input {
  lumberjack {
    port => 5000
      type => "logs"
      ssl_certificate => "/etc/logstash/logstash-forwarder.crt"
      ssl_key => "/etc/logstash/logstash-forwarder.key"
  }
}
EOF

cat > /etc/logstash/conf.d/20-output.conf << EOF
output {
  elasticsearch { host => localhost }
}
EOF

#kibana
apt-get -y install nginx apache2-utils
curl -L -o /tmp/kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
tar zxvf /tmp/kibana.tar.gz -C /tmp
mkdir /var/www && mv /tmp/kibana*/ /var/www/kibana

# this needs chef or something
sed -i '/elasticsearch:.*window.location.hostname.*9200.*/c\     elasticsearch: "http://"+window.location.hostname,' /var/www/kibana/config.js

cat > /etc/nginx/sites-available/kibana << EOF
server {
    listen                *:80 ;

    access_log            /var/log/nginx/access.log;

    location / {
      root  /var/www/kibana/;
      index  index.html  index.htm;
      auth_basic "Restricted";
      auth_basic_user_file /etc/nginx/conf.d/kibana.htpasswd;
   }

    location ~ ^/_aliases$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
    }

    location ~ ^/.*/_aliases$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
    }

    location ~ ^/_nodes$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
    }

    location ~ ^/.*/_search$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
    }

    location ~ ^/.*/_mapping {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
    }

    # Password protected end points
    location ~ ^/kibana-int/dashboard/.*$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
        limit_except GET {
            proxy_pass http://localhost:9200;
            auth_basic "Restricted";
            auth_basic_user_file /etc/nginx/conf.d/kibana.htpasswd;
        }
    }

    location ~ ^/kibana-int/temp.*$ {
        proxy_pass http://localhost:9200;
        proxy_read_timeout 90;
        limit_except GET {
            proxy_pass http://localhost:9200;
            auth_basic "Restricted";
            auth_basic_user_file /etc/nginx/conf.d/kibana.htpasswd;
        }
    }
}
EOF

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana

cat > /etc/rc.first-boot << EOF
#!/bin/bash
openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout /etc/logstash/logstash-forwarder.key -out /etc/logstash/logstash-forwarder.crt
htpasswd -b -c /etc/nginx/conf.d/kibana.htpasswd kibana kibana
EOF

chmod 755 /etc/rc.first-boot
