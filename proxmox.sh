#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# POSIX-compatible root check
if [ "$(id -u)" -ne 0 ]; then
    whiptail --title "Permission Denied" --msgbox "You must run this script as root!" 8 40
    exit 1
fi

# Disable ipv6, force ipv4
echo "Acquire::ForceIPv4 \"true\";" >> /etc/apt/apt.conf.d/99force-ipv4
apt update
apt install -y curl fastfetch fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban --now

# Clear the old configs
sed -i '/#--CUSTOM--/,$d' /root/.bashrc && sed -i "/^PS1='\\\\\\[/,\$d" /root/.bashrc 
echo -e "\n#--CUSTOM--\n" >> /root/.bashrc
echo -e "\n# Add Colors\nPS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '\n" >> /root/.bashrc
echo -e "\n# Show system info on every terminal\nfastfetch --logo proxmox\n" >> /root/.bashrc

# Refresh .bashrc for root
source ~/.bashrc


