# set pkg path for users
echo " "
echo " Setting PKG_PATH"
echo " "
echo " export PKG_PATH=http://ftp3.usa.openbsd.org/pub/OpenBSD/`uname -r`/packages/`arch -s`/ " >> /root/.profile

echo " "
echo " Setting sudo to work with vagrant "
echo " "
echo "# Uncomment to allow people in group wheel to run all commands without a password" >> /etc/sudoers
echo "%wheel        ALL=(ALL) NOPASSWD: SETENV: ALL" >> /etc/sudoers
