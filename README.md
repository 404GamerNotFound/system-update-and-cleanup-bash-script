
# Automated package maintenance tool for Debian-based Linux systems

This script suite automates the maintenance of a Debian-based Linux system. 
It handles package updates, upgrades all installed packages, removes obsolete packages, and cleans up the local package cache. If required, it will also trigger a system restart.

## Requirements

- A Debian-based Linux distribution (such as Ubuntu, Linux Mint or Debian).
- an MTA, such as `exim4`, and `mail` command should be configured correctly for mail notification purposes.

## Installation

(Skip this step if you'd rather perform the maintenance manually)

1. Make a `git clone https://github.com/404GamerNotFound/system-update-and-cleanup-bash-script.git` to any directory on your Linux system.
2. Go to the system-update-and-cleanup-bash-script directory : `cd /path/to/system-update-and-cleanup-bash-script`
3. Make the install script executable with the following command:
   ```
   chmod +x install.sh
   ```
4. Execute `install.sh` with `sudo`:
   ```
   sudo ./install.sh
   ```
5. Answer the few questions asked

You're all set !

## Usage

### Automation with Cron

In case you follow the installation process, scripts are scheduled for an automatic update process run by a cron job. 

You will be prompted to enter :
- an email address to be notified in case upgrades and/or system restart are required.
- a time of the day on which you want the package maintenance to be performed.
   
The installation script will then put the update and cleanup scripts in the right path (/usr/local/bin) for a system wide usage, they will also update the scripts and cron jobs, with the information you provided.

System updates would then be executed at the chosen time, when system cleanup will be performed one hour later (being delayed in case any system restart is required in between).

**Note:** Running system updates automatically should be done with caution, as there is a chance that an update could cause issues with the system and/or potential incompatibilities with some application. Hence the importance of the notification emails, so that you know when to check on your system to see if everything went smooth. 
**In any case, you should choose carefully the servers on which you decide to activate this automated maintenance.**

### Manual execution

You might want **not** to automate the process. In this case, **you should then skip the 'Installation' step**, in order to review, possibly edit and run each script manually with `sudo` to perform system updates and cleanup (in that order) only when you want to :

```
chmod +x system_update.sh
chmod +x system_cleanup.sh
sudo ./system_update.sh
sudo ./system_cleanup.sh
```

Beware thought, that doing so might induce a system restart when you run system_update.sh ! So make sure you're doing it at a time of the day when an unexpected restart won't affect anyone's work.

## Updating this tool

This package maintenance suite should not get any modification soon. But in case we upgrade something, getting the new version to work will be as simple as executing `git pull` to get up to date scripts, and running `sudo ./install.sh` again (see step 1). Commands and cron jobs will then be replaced/updated with the new informations provided.


## Troubleshooting

The two commands logs all their actions to `/var/log/system_update.log` and `/var/log/system_cleanup.log` respectively. If the scripts did not run as expected, you can check these log files for any error messages or warnings..

Furthermore, as soon as upgrades have been detected for your packages and/or a post upgrade system restart is required, an email is sent with relevant logs to the address you provided during the install process.


## License

This scripts suite is shared under the MIT License.


## Authors

- Tony Brüser / 404GamerNotFound
- Etienne B. / Loiseau2nuit
