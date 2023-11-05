#!/bin/bash

# System Update and Cleanup Script
# ---------------------------------
# This script automates the update and cleanup process for Debian-based Linux systems.
# It updates the package lists, upgrades all packages, performs a distribution upgrade,
# removes obsolete packages, and cleans up the package cache.
#
# Before using this script, ensure that you have backed up all important data. While updates
# generally are safe, there is always a small risk of system instability or data loss during
# the process. Use this script at your own risk.
#
# It is recommended to run this script initially in a testing environment before deploying
# it on a production system.
#
# Make sure that you have sufficient permissions to execute system updates and that your
# user is able to run commands with 'sudo'.

# Define the log file location
LOGFILE="/var/log/system_update_and_cleanup.log"

# Redirect all output and errors to the log file
exec > >(tee -a "$LOGFILE") 2>&1

echo "System update and upgrade process started: $(date)"

# Function to check the last exit status
check_status() {
    if [ $? -ne 0 ]; then
        echo "An error has occurred. Check the log file: $LOGFILE"
        exit 1
    fi
}

# Check if 'apt' is available on the system
if ! command -v apt > /dev/null; then
    echo "'apt' package manager is not installed on this system. Exiting."
    exit 1
fi

# Update the package sources
sudo apt update
check_status

# Upgrade the installed packages
sudo apt upgrade -y
check_status

# Perform a distribution upgrade
sudo apt dist-upgrade -y
check_status

# Remove unnecessary packages
sudo apt autoremove -y
check_status

# Clean the local repository cache
sudo apt autoclean
check_status

echo "System update and upgrade completed: $(date)"

# Check if a system restart is required
if [ -f /var/run/reboot-required ]; then
    echo "A system restart is required. Do you want to restart now? (yes/no)"
    read answer
    if [ "$answer" = "yes" ]; then
        sudo reboot
    else
        echo "Do not forget to restart the system later."
    fi
fi

echo "The script has been executed successfully."
