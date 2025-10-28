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
