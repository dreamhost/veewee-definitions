#!/bin/sh
#
#     ___   ___                       .___
#    /   \  \  | - L3 for OpenStack - | _/
#   /  _  \ |  | _______    ____    __| | ____
#  /  /_\  \|  |/ /\__  \  /    \  / __ |\__  \
# /    |    \    <  / __ \|   |  \/ /_/ | / __ \_
# \____|__  /__|_ \(____  /___|  /\____ |(____  /
#         \/     \/     \/     \/      \/     \/
#
# This script creates an Akanda image - powered by FreeBSD, Python, and
# Flask - and lets you customize it.
#
# Copyright (c) 2009 Reiner Rottmann. Released under the BSD license.
# Copyright (c) 2012 New Dream Network, LLC (DreamHost).
#
# First release 2009-06-20
# Akanda release 2012-10-14
#
# Notes:
#
# * Modified 2012 by DreamHost <dev-community@dreamhost.com> for use with
#   Akanda

###############################################################################
# Defaults
###############################################################################
ARCH=$(uname -p)         # Architecture
TZ=UTC                   # Time zones are in /usr/share/zoneinfo
# Additional packages that should be installed on the akanda appliance
PACKAGES="git python27-2.7.8 py27-pip wget dnsmasq bird6 py27-eventlet-0.14.0_1 py27-greenlet-0.4.2"


WDIR=/usr/local/akanda-livecdx            # Working directory
CDBOOTDIR=$WDIR/$MAJ.$MIN/$ARCH        # CD Boot directory
OUTDIR=/tmp
HERE=`pwd`

DNS=8.8.8.8            # Google DNS Server to use in live cd (change accordingly)


#CLEANUP=no                    # Clean up downloaded files and workdir (disabled by default)
CLEANUP=yes

# End of user configuration
###############################################################################

# global variables

SCRIPTNAME=$(basename $0 .sh)

EXIT_SUCCESS=0
EXIT_FAILED=1
EXIT_ERROR=2
EXIT_BUG=10

VERSION="1.0.0"

# base functions

# This function may be used for cleanup before ending the program
function cleanup {
    echo
}

function makedeps {
    echo "[*] Installing dependencies for make"
    pkg install bison
    pkg install m4
    pkg install gmake
}


# This is the main function that sets up the Freebsd Akanda appliance
function appliance {
    echo "[*] Akanda (powered by FreeBSD) customization script"
    echo "[*] The software is released under BSD license. Use it at your own risk!" >&2
    echo "[*] Copyright (c) 2009 Reiner Rottmann." >&2
    echo "[*] Copyright (c) 2012 New Dream Network, LLC (DreamHost)." >&2
    echo "[*] This script is released under the BSD License."
    uname -a | grep FreeBSD || echo "[*] WARNING: This software should run on an FreeBSD System!"
    date

    #echo "[*] Disabling some kernel devices"
    #echo 'disable mpbios' | config -ef $CDBOOTDIR/bsd
    #echo 'disable usb' | config -ef $CDBOOTDIR/bsd

    echo "[*] Creating motd file..."
    cat >/etc/motd <<EOF

    ___   ___                       .___
   /   \\  \\  | - L3 for OpenStack - | _/
  /  _  \\ |  | _______    ____    __| | ____
 /  /_\\  \\|  |/ /\\__  \\  /    \\  / __ |\\__  \\
/    |    \\    <  / __ \\|   |  \\/ /_/ | / __ \\_
\\____|__  /__|_ \\(____  /___|  /\\____ |(____  /
        \\/     \\/     \\/     \\/      \\/     \\/
Welcome to Akanda: Powered by FreeBSD.


EOF

    echo "[*] Setting name..."
    cat > /etc/myname <<EOF
    akanda
EOF

#echo "[*] Modifying the library path..."
#cat > $WDIR/root/.cshrc << EOF
# Workaround for missing libraries:
#export LD_LIBRARY_PATH=/usr/local/lib
#EOF
#cat > $WDIR/root/.profile << EOF
# Workaround for missing libraries:
#export LD_LIBRARY_PATH=/usr/local/lib
#EOF
#mkdir -p $WDIR/etc/profile
#cat > $WDIR/etc/profile/.cshrc << EOF
# Workaround for missing libraries:
#export LD_LIBRARY_PATH=/usr/local/lib
#EOF
#cat > $WDIR/etc/profile/.profile << EOF
# Workaround for missing libraries:
#export LD_LIBRARY_PATH=/usr/local/lib
#EOF

echo "[*] Using DNS ($DNS) in livecd environment..."
echo "nameserver $DNS" > /etc/resolv.conf

echo "[*] Disabling services...."
cat >> /etc/rc.conf.local <<EOF
amd_enable="NO"
sendmail_enable="NO"
varmfs="YES"
hostname="akanda"
pf_enable="YES"
sshd_enable="YES"
## This is the default.  Leaving here in case we need to tweak.
ipv6_activate_all_interfaces="NO"
EOF

echo "[*] Setting default password..."
#cp $HERE/etc/master.passwd $WDIR/etc/master.passwd
#cp $HERE/etc/passwd $WDIR/etc/passwd
#cp $HERE/etc/group $WDIR/etc/group
#cp /root/akanda-master-password $WDIR/etc
echo '$2a$08$CD23PpFuZ91D2piAIy/FdOuaJBygVVDoGeJD33lhmauHKIhgOIAEe' | pw usermod root -H 0

echo "[*] Installing additional packages..."
cat > /tmp/packages.sh <<EOF
#!/bin/sh -e
export LD_LIBRARY_PATH=/usr/local/lib
/sbin/ldconfig
export PKG_PATH=$(echo $PKG_PATH | sed 's#\ ##g')
for i in $PACKAGES
do
   pkg install \$i
done
/sbin/ldconfig
EOF

chmod +x /tmp/packages.sh
/tmp/packages.sh || exit 1
rm /tmp/packages.sh

ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
ln -sf /usr/local/bin/pip-2.7 /usr/local/bin/pip

cd /tmp && git clone https://github.com/dreamhost/akanda-appliance.git
cd akanda-appliance && python setup.py install

mkdir /etc/dnsmasq.d
cat > /etc/dnsmasq.conf <<EOF
bind-interfaces
leasefile-ro
domain-needed
bogus-priv
no-hosts
no-poll
strict-order
dhcp-lease-max=256
conf-dir=/etc/dnsmasq.d
EOF


#echo "[*] Add rc.d scripts...."
#cp $HERE/etc/rc.d/sshd /etc/rc.d/sshd
#cp $HERE/etc/rc.d/metadata /etc/rc.d/metadata
#chmod 555 /etc/rc.d/sshd
#chmod 555 /etc/rc.d/metadata

echo "[*] Disable fsck"
touch /fastboot

#echo "[*] Update newsyslog.conf"
#cp $HERE/etc/newsyslog.conf /etc/newsyslog.conf

echo "[*] Add rc.local file...."
cat > /etc/rc.local << EOF
# Site-specific startup actions, daemons, and other things which
# can be done AFTER your system goes into securemode.  For actions
# which should be done BEFORE your system has gone into securemode
# please see /etc/rc.securelevel.
#

# set keyboard to US
echo "Setting keyboard language to us:"
/sbin/kbd us

# set TZ
rm /etc/localtime
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo "Enabling forwarding..."
sysctl -w net.inet.ip.forwarding=1
sysctl -w net.inet6.ip6.forwarding=1

echo "Configuring http for management interface..."
/usr/local/bin/akanda-configure-gunicorn

echo "Configuring pf rules for start up..."
/usr/local/bin/akanda-configure-default-pf
/sbin/pfctl -vf /etc/pf.conf

/etc/rc.d/sshd restart
/usr/local/bin/gunicorn -c /etc/akanda_gunicorn_config akanda.router.api.server:app
EOF
#cp $HERE/etc/rc.local $WDIR/etc/rc.local

#echo "[*] Entering Akanda livecd builder (chroot environment)."
#echo "[*] Once you have finished your modifications, type \"exit\""

#    chroot $WDIR

    echo "[*] Deleting sensitive information..."
    rm -f /root/{.history,.viminfo}
    rm -f /home/*/{.history,.viminfo}

    echo "[*] Empty log files..."
    for log_file in $(find /var/log -type f)
    do
        echo "" > $log_file
    done

    echo "[*] Remove ports and src (only on the appliance)..."
    rm -rf /usr/{src,ports,xenocara}/*

    #echo "[*] Removing ssh host keys..."
    #rm -f /etc/ssh/*key*

    echo "[*] Adding ssh key...]"
    mkdir /root/.ssh
    chmod 700 /root/.ssh
    cp $HERE/etc/key /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys

    echo "[*] Saving creation timestamp..."
    date > /etc/appliance-release

    echo "[*] Saving default timezone..."
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/$TZ /etc/localtime


    echo "[*] Please support the FreeBSD project by buying official cd sets or donating some money!"
    echo "[*] Enjoy Akanda!"
    date
    echo "[*] Done."
}

# Skip already used arguments
shift $(( OPTIND - 1 ))

# Loop over all arguments
for ARG ; do
        if [[ $VERBOSE = y ]] ; then
                echo -n "Argument: "
        fi
        #echo $ARG
done


# Call (main-)function
makedeps
appliance

#
cleanup
exit $EXIT_SUCCESS

