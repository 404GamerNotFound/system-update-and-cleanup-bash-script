#!/bin/bash

# Automated package maintenance for Debian-based Linux systems
# system_cleanup.sh
# ---------------------------------
# This script automates the cleanup process for Debian-based Linux systems.
# It removes obsolete packages, and cleans up the package cache.
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
LOGFILE="/var/log/system_cleanup.log"

# Redirect all output and errors to the log file
exec > >(tee -a "$LOGFILE") 2>&1

# Function to check the last exit status
check_status() {
    if [ $? -ne 0 ]; then
        echo "[$(date)] An error has occurred. Check the log file: $LOGFILE"
        exit 1
    else
	echo "[$(date)] OK"
    fi
}

echo "[$(date)] System cleanup is starting ..."

echo "[$(date)] Remove unnecessary packages"
apt-get autoremove -y
check_status

echo "[$(date)] Clean the local repository cache"
apt-get autoclean
check_status

echo "[$(date)] System and local repository cache are now clean !"
