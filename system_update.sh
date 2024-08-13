#!/bin/bash

# Automated package maintenance for Debian-based Linux systems
# system_update.sh
# ------------------------------------------------------------
# This script automates the update process for Debian-based Linux systems.
# It updates the package lists, upgrades all packages and perform a system restart if required
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
LOGFILE="/var/log/system_update.log"

# Redirect all output and errors to the log file
exec >> $LOGFILE 2>&1

# Function to check the last exit status
check_status() {
    if [ $? -ne 0 ]; then
        echo "[$(date)] An error has occurred. Check the log file: $LOGFILE"
        exit 1
    else
	echo "[$(date)] OK"
    fi
}

echo "[$(date)] Update the package sources"
apt-get update
check_status

echo "[$(date)] Checking for upgrades ..."

# Are there packages in need for an upgrade ?
# Execute command (equiv. to 'apt list --upgradable') and capture the output
updates=$(apt-get --just-print upgrade | grep "^Inst")

# Verify if output is empty
if [ -z "$updates" ]; then
    echo "[$(date)] No package needs to be upgraded. System is up to date. Exiting now."
    exit 0  # No need to go further at this point
else
    {
	# At this point, if upgrades are likely to be performed, and wether or not the system should be restarted
	# we shall be informed by email, assuming exim4+mail are installed and correctly configured on the system
	if ! command -v mail > /dev/null; then
	    echo "[$(date)] ERROR : 'mail' command is not available on this system. No notification will be sent"
	fi

        echo "[$(date)] Starting packages full-upgrade ..."

        # Upgrade the installed packages
        # keeping every modified by config file as is (new one suffixed .dpkg-dist if needed later)
        # see https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/#:~:text=Avoiding%20the%20conffile%20prompt
        DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade -y
        check_status

        echo "[$(date)] Packages upgrade completed. System is up to date"

        # Check if a system restart is required
        if [ -f /var/run/reboot-required ]; then
            echo "[$(date)] A system restart is required. Proceeding now !"
            /usr/bin/systemctl reboot
        else
            echo "[$(date)] No system restart required. Exiting now."
            exit 0
        fi
    }|mail -s "Server upgrade status" someone@domain.tld 2>&1
fi
