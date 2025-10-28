#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# POSIX-compatible root check
if [ "$(id -u)" -ne 0 ]; then
    whiptail --title "Permission Denied" --msgbox "You must run this script as root!" 8 40
    exit 1
fi
