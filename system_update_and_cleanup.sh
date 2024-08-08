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

echo "System update and upgrade process started: $(date)"

# Function to check the last exit status
check_status() {
    if [ $? -ne 0 ]; then
        echo "An error has occurred. Check the log file: $LOGFILE"
        exit 1
    fi
}

# Update the package sources
${SUDO} apt-get update
check_status

# Is there a need for an upgrade ?
execute_if_needed() {
    # Execute command (equiv. to 'apt list --upgradable') and capture the output
    updates=$(apt-get --just-print upgrade | grep "^Inst")

    # Verify if output is empty
    if [ -z "$updates" ]; then
        echo "No package to be upgraded. Exiting now."
        exit 0  # No need to go further at this point
    else
        echo "Performing full-upgrade now :"

        # Upgrade the installed packages
        ${SUDO} apt-get full-upgrade -y
        check_status
        
        # Remove unnecessary packages
        ${SUDO} apt-get autoremove -y
        check_status
        
        # Clean the local repository cache
        ${SUDO} apt-get autoclean
        check_status

        echo "System update and upgrade completed: $(date)"

        # Check if a system restart is required
        if [ -f /var/run/reboot-required ]; then
            echo "A system restart is required. Do you want to restart now? (yes/no)"
            read answer
            if [ "$answer" = "yes" ]; then
                ${SUDO} reboot
            else
                echo "Do not forget to restart the system later."
            fi
        fi
    
        echo "The script has been executed successfully."
    
    fi
}
execute_if_needed


