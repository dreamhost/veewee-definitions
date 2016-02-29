# Base install

# Must exclude kernel for now. Otherwise, kernel gets upgraded before reboot,
# but VirtualBox tools get compiled against the old kernel, so the fresh
# image will refuse to start under Vagrant.
yum -y update --exclude kernel*
