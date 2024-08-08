# System Update and Cleanup Scripts

Those scripts are designed to automate the process of updating and cleaning up a Debian-based Linux system. They update the packages list, upgrade all packages, remove obsolete packages and clean up the local package cache. If necessary, a system restart is also performed before cleaning up.

## Requirements

- A Debian-based Linux distribution (such as Ubuntu or Debian)
- `sudo` privileges for the executing user

## Installation

(Skip this step if you'd rather perform the maintenance manually)

1. Make a `git clone https://github.com/Loiseau2nuit/system-update-and-cleanup-bash-script.git` to any directory on your Linux system.
2. Go to the system-update-and-cleanup-bash-script directory : `cd /path/to/system-update-and-cleanup-bash-script`
3. Make the install script executable with the following command:
   ```
   chmod +x install.sh
   ```
4. Execute `install.sh` with `sudo`:
   ```
   sudo ./install.sh
   ```
5. Answer the three questions asked

You're all set !

## Usage

### Automation with Cron

In case you follow the installation process, you can schedule the scripts to run regularly using cron. You'll be prompted to choose :
- a username to execute the script
- an email address to notify in case upgrades are on the go. You won't be notified if nothing is to be upgraded
- a time of the day on which you want to perform the maintenance.
   
The installation script will then update your scripts and crontab accordingly.
System updates will be executed at the chosen time, system cleanup will be one hour after (in case any restart is needed in between).

**Note:** Running system updates automatically should be done with caution, as there's a (very) small (indeed) chance that an update could cause issues with the system, especially if a restart is required. 
Thus the notification email, so that you know when to check on your system to see if everything went smooth.


### manual

You might want not to automate the process. In this case, you can skip the 'Installation' step, then review, edit and run each script manually with `sudo` to perform system update and cleanup (in that specific order !) :

```
chmod +x system_update.sh
chmod +x system_cleanup.sh
sudo ./system_update.sh
sudo ./system_cleanup.sh
```

Beware thought, than doing so might induce a system restart, as planned in system_update.sh ! So make sure you're doing it at a time of the day when an unexpected restart won't affect anyone's work.


## Troubleshooting


The scripts logs all their actions to `/var/log/system_update_and_cleanup.log`, so you can review what the script did at any time by examining this file.

As soon as upgrades have been detected for your system, an email is sent to the address you'll choose during the install process

If the script does not execute as expected, check this log file for any error messages or warnings.

## License

This script is shared under the MIT License.

## Authors

Tony Brüser / 404GamerNotFound

Etienne B. / Loiseau2nuit
