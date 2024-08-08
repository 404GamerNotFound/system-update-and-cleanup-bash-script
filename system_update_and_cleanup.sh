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

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# Define the log file location
LOGFILE="/var/log/system_update_and_cleanup.log"

# Redirect all output and errors to the log file
exec > >(tee -a "$LOGFILE") 2>&1

# Function to check the last exit status
check_status() {
    if [ $? -ne 0 ]; then
        echo "[$(date)] An error has occurred. Check the log file: $LOGFILE"
        exit 1
    fi
}

# Update the package sources
${SUDO} apt-get update
check_status

# At this point, if upgrades are likely to be performed, and if wether or not the system should be restarted
# we shall be informed by email, assuming exim4+mail are installed and correctly configured on the system
if ! command -v mail > /dev/null; then
    echo "[$(date)] ERROR : 'mail' is not installed on this system."
fi

echo "[$(date)] System update and upgrade process started"    

# Are there packages in need for an upgrade ?
# Execute command (equiv. to 'apt list --upgradable') and capture the output
updates=$(apt-get --just-print upgrade | grep "^Inst")

# Verify if output is empty
if [ -z "$updates" ]; then
    echo "[$(date)] No package to be upgraded. Exiting now."
    exit 0  # No need to go further at this point
else
    {
        echo "[$(date)] Performing full-upgrade now !"

        # Upgrade the installed packages
        # keeping every modified by config file as is (new one suffixed .dpkg-dist if needed later)
        # see https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/#:~:text=Avoiding%20the%20conffile%20prompt
        DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade -y
        check_status
            
        # Remove unnecessary packages
        ${SUDO} apt-get autoremove -y
        check_status
            
        # Clean the local repository cache
        ${SUDO} apt-get autoclean
        check_status
    
        echo "[$(date)] System update and upgrade completed"

        # Check if a system restart is required
        if [ -f /var/run/reboot-required ]; then
            echo "[$(date)] A system restart has been required"
            ${SUDO} reboot
        else
            echo "[$(date)] No system restart was required"
            exit 0
        fi        
    }|mail -s "Server upgrade status" someone@domain.tld 2>&1
fi
