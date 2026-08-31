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
apt install -y curl fastfetch fail2ban sudo dialog whiptail
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban --now

# Ask for the primary username(to control their .bashrc)
username=$(whiptail \
    --backtitle "Debian Setup Wizard" \
    --title "User Configuration" \
    --inputbox "Enter your username:" 8 40 \
    3>&1 1>&2 2>&3)
echo "You entered: $username"

# Check if the .bashrc exists for that user
if [ -f "/home/$username/.bashrc" ]; then
    echo ".bashrc exists for user $username"
else
    echo ".bashrc does NOT exist for user $username"
    exit 1
fi

# Clear the old configs
sed -i '/#--CUSTOM--/,$d' /home/$username/.bashrc && sed -i "/^PS1='\\\\\\[/,\$d" /home/$username/.bashrc
sed -i '/#--CUSTOM--/,$d' /root/.bashrc && sed -i "/^PS1='\\\\\\[/,\$d" /root/.bashrc 
echo -e "\n#--CUSTOM--\n" >> /home/$username/.bashrc
echo -e "\n#--CUSTOM--\n" >> /root/.bashrc
echo -e "\n# Add Colors\nPS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '\n" >> /home/$username/.bashrc
echo -e "\n# Add Colors\nPS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '\n" >> /root/.bashrc
echo -e "\n# Show system info on every terminal\nfastfetch\n" >> /home/$username/.bashrc
echo -e "\n# Show system info on every terminal\nfastfetch\n" >> /root/.bashrc

# Add the user to the sudo group
usermod -aG sudo $username

# Set the timeout for sudo to be 4 hours
echo "Defaults:$username timestamp_timeout=240" | sudo EDITOR='tee -a' visudo

# Refresh .bashrc for root
source ~/.bashrc

# Add 'contrib' & 'non-free' to update repositories
sed -i 's/trixie main non-free-firmware/trixie main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sed -i 's/trixie-security main non-free-firmware/trixie-security main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sed -i 's/trixie-updates main non-free-firmware/trixie-updates main contrib non-free non-free-firmware/g' /etc/apt/sources.list

