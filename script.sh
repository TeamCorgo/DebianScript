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
echo -e "\n# # Show system info on every terminal\nfastfetch\n" >> /home/$username/.bashrc
echo -e "\n# # Show system info on every terminal\nfastfetch\n" >> /root/.bashrc

# Ask if user wants to install sudo
if whiptail --backtitle "Debian Setup Wizard" \
            --title "Install sudo?" \
            --yesno "Do you want to install sudo?" 8 40; then
    echo "Installing sudo..."
    apt install -y sudo
    echo "sudo installed successfully."
    # Add the user to the sudo group
    usermod -aG sudo $username
    # Set the timeout

    echo "Defaults:$username timestamp_timeout=240" | sudo EDITOR='tee -a' visudo
else
    echo "Skipping sudo installation."
fi

# Refresh .bashrc for root
source ~/.bashrc


