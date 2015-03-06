#!/bin/bash 

curl -L https://jenkins-ci.org/debian/jenkins-ci.org.key |apt-key add -
add-apt-repository "deb http://pkg.jenkins-ci.org/debian binary/"
DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins git nginx apache2-utils

cat > /etc/nginx/sites-available/jenkins << 'EOF'
server {
    listen                *:80 ;
    
    access_log            /var/log/nginx/access.log;

    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/conf.d/jenkins.htpasswd;
        proxy_pass http://localhost:8080;
        proxy_read_timeout 90;
   }
}
EOF

rm -fv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins

cat > /etc/rc.first-boot << 'EOF'
#!/bin/bash
htpasswd -b -c /etc/nginx/conf.d/jenkins.htpasswd jenkins jenkins
EOF

chmod 755 /etc/rc.first-boot
