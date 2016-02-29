# Base install

# Must exclude kernel for now. Otherwise, kernel gets upgraded before reboot,
# but VirtualBox tools get compiled against the old kernel, so the fresh
# image will refuse to start under Vagrant.
dnf -y update --exclude kernel*
