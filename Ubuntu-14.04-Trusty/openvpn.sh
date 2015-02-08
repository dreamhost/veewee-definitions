#!/bin/bash 

DEBIAN_FRONTEND=noninteractive apt-get install -y openvpn easy-rsa openssl ipcalc iptables-persistent
mkdir /etc/openvpn/easy-rsa && mkdir /etc/openvpn/easy-rsa/keys
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

cat > /etc/openvpn/easy-rsa/vars << EOF
export OPENSSL="/usr/bin/openssl"
export KEY_CONFIG="/etc/openvpn/easy-rsa/openssl-1.0.0.cnf"
export KEY_DIR="/etc/openvpn/easy-rsa/keys"
export KEY_SIZE="1024"
export KEY_COUNTRY="US"
export KEY_PROVINCE="VA"
export KEY_CITY="Ashburn"
export KEY_ORG="OpenVPN"
export KEY_EMAIL="admin@localhost"
export KEY_NAME=openvpn
export KEY_OU=openvpn
EOF

cat > /etc/openvpn/server.conf << EOF
tls-server
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/openvpn.crt
key /etc/openvpn/openvpn.key
dh /etc/openvpn/dh1024.pem
client-to-client
keepalive 10 120
comp-lzo
persist-key
persist-tun
server 172.20.0.0 255.255.255.0
EOF

echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

cat > /etc/iptables/rules.v4 << EOF
*nat
:PREROUTING ACCEPT [239:10258]
:INPUT ACCEPT [236:10026]
:OUTPUT ACCEPT [53:3555]
:POSTROUTING ACCEPT [53:3555]
-A POSTROUTING -s 172.20.0.0/24 -o eth0 -j MASQUERADE
COMMIT
EOF

cat > /etc/rc.first-boot << 'EOF'
#!/bin/bash
EASY_RSA="/etc/openvpn/easy-rsa"
cd $EASY_RSA
source ./vars
./clean-all
$EASY_RSA/pkitool --initca
$EASY_RSA/pkitool --server openvpn
./build-dh

echo "creating client key"
$EASY_RSA/pkitool client

cp $EASY_RSA/keys/openvpn.key $EASY_RSA/keys/openvpn.crt $EASY_RSA/keys/dh1024.pem $EASY_RSA/keys/ca.crt /etc/openvpn/

IP_CIDR=`ip -o -f inet addr show eth0 | awk '/scope global/ {print $4}'`
IP_NETMASK=`ipcalc -n -b $IP_CIDR |egrep ^Netmask: |awk '{print $2}'`
IP_NETWORK=`ipcalc -n -b $IP_CIDR |egrep ^Network: |awk '{print $2}' | awk -F \/ '{print $1}'`

echo "push \"route $IP_NETWORK $IP_NETMASK\" " >> /etc/openvpn/server.conf

CLIENT_KEY_DIR="/home/dhc-user/openvpn-client-keys"
mkdir $CLIENT_KEY_DIR && chown dhc-user.dhc-user $CLIENT_KEY_DIR
cp $EASY_RSA/keys/client.crt $EASY_RSA/keys/client.key /etc/openvpn/ca.crt $CLIENT_KEY_DIR
chown dhc-user.dhc-user $CLIENT_KEY_DIR/*

/etc/init.d/openvpn restart && touch /etc/openvpn/.ready
EOF

chmod 755 /etc/rc.first-boot
