# System Update and Cleanup Script

This script `system_update_and_cleanup.sh` is designed to automate the process of updating and cleaning up a Debian-based Linux system. It updates the package list, upgrades all packages, performs a distribution upgrade, removes obsolete packages, and cleans up the local package cache. If necessary, it also prompts for a system restart.

## Requirements

- A Debian-based Linux distribution (such as Ubuntu or Debian)
- `sudo` privileges for the executing user

## Installation

1. Copy `system_update_and_cleanup.sh` to a directory on your Linux system.
2. Make the script executable with the following command:
   ```
   chmod +x /path/to/system_update_and_cleanup.sh
   ```
3. Test the script manually with `sudo` to ensure it works correctly:
   ```
   sudo /path/to/system_update_and_cleanup.sh
   ```

## Logging

The script logs all its actions to `/var/log/system_update_and_cleanup.log`, so you can review what the script did at any time by examining this file.

## Usage

Run the script with `sudo` to perform system update and cleanup:
```
sudo /path/to/system_update_and_cleanup.sh
```

## Automation with Cron

You can schedule the script to run regularly using cron. Here's how to add a cron job to run the script every day at 3 am:

1. Open the current user's crontab file:
   ```
   crontab -e
   ```
2. Add the following line to schedule the job (ensure you replace `/path/to/` with the actual path to the script):
   ```
   0 3 * * * /usr/bin/sudo /path/to/system_update_and_cleanup.sh >/dev/null 2>&1
   ```
3. Save and close the crontab.

This cron entry runs the script at 3 am daily. The `>/dev/null 2>&1` part suppresses the output since cron jobs typically run without a terminal.

**Note:** Running system updates automatically should be done with caution, as there's a small chance that an update could cause issues with the system, especially if a restart is required or if there are prompts during the update process that need to be addressed manually.

## Troubleshooting

If the script does not execute as expected, check the log file at `/var/log/system_update_and_cleanup.log` for any error messages or warnings.

## License

This script is shared under the MIT License.

## Author

Tony Brüser / 404GamerNotFound
