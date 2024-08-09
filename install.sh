#!/bin/bash

# System Update and Cleanup initialization Script
# -----------------------------------------------
# This script collects basic info in order to configure the two other scripts to suit your needs.
# Then it sets them executable and adds them to cron for automatic execution
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

echo "AUTOMATED PACKAGE MAINTENANCE FOR DEBIAN-BASED LINUX SYSTEMS"
echo "This script suite automates the maintenance of a Debian-based Linux system. It handles package updates, upgrades all installed packages, removes obsolete packages, and cleans up the local package cache. If required, it will also trigger a system restart."
echo "WARNING : Before you go further with this, you should review the 2 scripts system_update.sh and system_cleanup.sh to make sure they suit your needs and, give them a first manual run to make sure everything is OK. Please refer to the documentation (or README.md file) for more information."

# Function to validate an email address
is_valid_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}


# 1. Copying files in path for a system wide utilization (+ remove .sh extension)

# Check if files exist and confirm replacement
if [ -f /usr/local/bin/system_update ] || [ -f /usr/local/bin/system_cleanup ]; then
    echo "-----------------------------------------------------------"
    read -p "Files already exist in /usr/local/bin/. Do you want to replace them? (y/n): " choice
    if [ "$choice" = "y" ]; then
        ${SUDO} cp -f system_*.sh /usr/local/bin/
        ${SUDO} mv -f /usr/local/bin/system_*.sh /usr/local/bin/system_*
	echo "Done."
    else
        echo "Files not replaced. Aborting !"
	exit 1
    fi
else
    ${SUDO} cp system_*.sh /usr/local/bin/
    ${SUDO} mv /usr/local/bin/system_*.sh /usr/local/bin/system_*
fi


# 2. Ask for the email address for notifications (mandatory)
while true; do
    echo "-----------------------------------------------------------"
    echo "Please, enter the email address you wish to be notified on :"
    read -r email

    # Validate the email address
    if is_valid_email "$email"; then
        echo "Valid email address. Updating system_update command..."
        
        # Replace 'someone@domain.tld' in system_update.sh with the provided email address
        sed -i "s/someone@domain.tld/$email/" /usr/local/bin/system_update
        
        echo "Email address updated successfully."
        break
    else
        echo "Invalid email address. Please try again."
    fi
done

# 3. Ask for the time of day to perform the maintenance routine
while true; do
    echo "What time should the package maintenance begin? (choose an integer between 0 (midnight) and 23 (11PM))"
    read -r time

    # Check if the input is an integer between 0 and 23
    if [[ "$time" =~ ^[0-9]+$ ]] && [ "$time" -ge 0 ] && [ "$time" -le 23 ]; then
        echo "Valid time selected: $time:00."
        break
    else
        echo "Invalid input. Please enter a number between 0 and 23."
    fi
done

# 4. Schedule the maintenance tasks
# Define the paths to the scripts for further reference
update_script="/usr/local/bin/system_update"
cleanup_script="/usr/local/bin/system_cleanup"

# Calculate the time for the cleanup script (1 hour after the chosen time)
cleanup_time=$(( (time + 1) % 24 ))

# Define the cron job entries
update_job="0 $time * * * root /usr/bin/sudo $update_script"
cleanup_job="0 $cleanup_time * * * root /usr/bin/sudo $cleanup_script"

# Define the cron file paths
update_cron_file="/etc/cron.d/system_update"
cleanup_cron_file="/etc/cron.d/system_cleanup"

# Create or replace the cron files with the new job entries
echo "$update_job" | ${SUDO} tee "$update_cron_file" > /dev/null
echo "$cleanup_job" | ${SUDO} tee "$cleanup_cron_file" > /dev/null

# Set the correct permissions for the cron files
${SUDO} chmod 644 "$update_cron_file"
${SUDO} chmod 644 "$cleanup_cron_file"

# Ensure that the files are owned by root
${SUDO} chown root:root "$update_cron_file"
${SUDO} chown root:root "$cleanup_cron_file"

echo "Cron job created or updated successfully."
echo "Packages updates will run daily at $time:00."
echo "System cleanup will run daily at $cleanup_time:00."
echo "The email address $email will be notified if an upgrade or a system restart occurs."
echo "See also /var/log/system_update.log and system_cleanup.log for more detailled outputs."


# 6. Make the scripts executable
${SUDO} chmod +x "$update_script"
${SUDO} chmod +x "$cleanup_script"

echo "You're all set ! :-)"
exit 0
