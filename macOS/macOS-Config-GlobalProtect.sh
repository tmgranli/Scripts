#!/bin/bash
## Description: Checks for global preferences file and populates
## it with the default portal if needed.
## Body ###########################################################
## Declare Variables ##############################################

# Get current Console user
active_user=$( stat -f “%Su” /dev/console )

# Global Prefs File
gPrefs=/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist

## Logic ##########################################################

# Check to see if the global preference file already exists…
if [[ -e $gPrefs ]]; then
echo “Default global portal already exists. Skipping.”
else
echo “Setting default global portal to: your.portal.here.com”
# If it does not already exist, create it and populate the default portal using the echo command
echo ‘

Palo Alto Networks

GlobalProtect

PanSetup

Portal
portal.tull.se
Prelogon
0

Settings

connect-method
on-demand



‘ > $gPrefs
echo $?
# Kill the Preference caching daemon to prevent it from overwriting any changes
killall cfprefsd
echo $?
fi
# Check exit code.
exit $?