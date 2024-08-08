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

echo "SYSTEM UPDATE AND CLEANUP SCRIPT"
echo "This script ensemble is designed to automate the process of updating and cleaning up a Debian-based Linux system. It updates the package list, upgrades all packages, removes obsolete packages, and cleans up the local package cache. If necessary, it also performs a system restart."
echo "WARNING : You should first manually test system_update.sh and system_cleanup.sh and make sure they suit your needs, before setting up their automation !"

# Function to validate an email address
is_valid_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

# 1. Ask for a user to perform the tasks (user must have sudo privileges and shouldn't be root)
while true; do
    echo "-----------------------------------------------------------"
    echo "Please choose a user to perform the tasks"
    echo "User must exit on the system, have sudo privileges and shouldn't be root"
    read -r user

    # Check if the user input is empty
    if [ -z "$user" ]; then
        echo "No user provided. Please try again."
        continue
    fi

    # Check if the user is "root"
    if [ "$user" = "root" ]; then
        echo "The user cannot be root. Please choose another user."
        continue
    fi

    # Check if the user exists on the system
    if ! id "$user" &>/dev/null; then
        echo "User '$user' does not exist. Please try again."
        continue
    fi

    # Check if the user is part of the sudo group
    if groups "$user" | grep -qw "sudo"; then
        echo "User '$user' has sudo privileges."
        break
    else
        echo "User '$user' does not have sudo privileges. Please choose another user."
    fi
done

# 2. Ask for the email address for notifications (mandatory)
while true; do
    echo "-----------------------------------------------------------"
    echo "Please, type the email address you wish to be notified on (mandatory):"
    read -r email

    # Validate the email address
    if is_valid_email "$email"; then
        echo "Valid email address. Updating system_update.sh..."
        
        # Replace 'someone@domain.tld' in system_update.sh with the provided email address
        sed -i "s/someone@domain.tld/$email/" ./system_update.sh
        
        echo "Email address updated successfully."
        break
    else
        echo "Invalid email address. Please try again."
    fi
done

# 3. Ask for the time of day to perform the maintenance routine
while true; do
    echo "What time of the day do you wish to perform the maintenance routine? (choose a strict number between 0 (midnight) and 23 (11PM))"
    read -r time

    # Check if the input is an integer between 0 and 23
    if [[ "$time" =~ ^[0-9]+$ ]] && [ "$time" -ge 0 ] && [ "$time" -le 23 ]; then
        echo "Valid time selected: $time:00."
        break
    else
        echo "Invalid input. Please enter a number between 0 and 23."
    fi
done

# 4. Check if the user's crontab exists, and create it if not
if ! crontab -l -u "$user" &>/dev/null; then
    echo "No crontab for user '$user'. Creating a new crontab."
    echo "" | crontab -u "$user" -
fi

# 5. Update the crontab for the selected user
# Define the paths to the scripts (assuming they are in the same directory as this script)
script_dir="$(dirname "$(realpath "$0")")"
update_script="$script_dir/system_update.sh"
cleanup_script="$script_dir/system_cleanup.sh"

# Calculate the time for the cleanup script (1 hour after the chosen time)
cleanup_time=$(( (time + 1) % 24 ))

# Update the crontab for the specified user
(
    crontab -l -u "$user" 2>/dev/null
    echo "0 $time * * * /usr/bin/sudo $update_script"
    echo "0 $cleanup_time * * * /usr/bin/sudo $cleanup_script"
) | crontab -u "$user" -

echo "Crontab updated for user '$user'."
echo "System update will run daily at $time:00."
echo "System cleanup will run daily at $cleanup_time:00."
echo "Email $email will be notified only if an upgrade and/or system restart occurs."
echo "See also /var/log/system_update_and_cleanup.log for more detailled outputs"


# 6. Make the scripts executable
${SUDO} chmod +x system_update.sh
${SUDO} chmod +x system_cleanup.sh

echo "you're all set ! :-)"
exit 0
