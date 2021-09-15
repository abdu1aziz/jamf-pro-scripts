#!/bin/bash
#
#

# GET current user information.

fname=$( /usr/bin/id -F)
username=$( /usr/bin/id -un)



echo "Provisioning User $fname ($username)"


# AppleScript command for Ask Prompt for department.

userPrompt="Choose From List {\"Accounting\", \"Sales\", \"Graphic Designing\"} with prompt \"Welcome $fname! Let's get Your Mac Setup. Please choose your department \"with title \"Provision Your Mac\""


# Run Following Commands

department=$( /usr/bin/osascript -e "$userPrompt" )

echo "Provisioning for $department"


# Apple Script Command to ask user for asset tag

userPrompt="display dialog \"Enter this Mac's Asset Tag\" with title \"Preparing Your Mac\""


assetTag=$( /usr/bin/osascript -e "$userPrompt" )

echo "Your Device's Asset Tag: $assetTag"


# Building Mac For Following Department

# Global Settings

/usr/local/bin/jamf policy -event settimezonechicago


if [[ "$department" = "Accounting" ]]; then

    echo "Provisioning Your Mac For Accounting Department..."

    /usr/local/bin/jamf/ policy -event installchrome
    /usr/local/bin/jamf/ policy -event installoffice

    # User Third-Party WebApplication That only runs on Firefox.
    /usr/local/bin/jamf/ policy -event installfirefox

elif [[ "$department" = "Sales" ]]; then


    echo "Provisioning Your Mac For Sales Department..."

    /usr/local/bin/jamf/ policy -event installchrome
    /usr/local/bin/jamf/ policy -event installoffice
    /usr/local/bin/jamf/ policy -event installzoom

else

    echo "Provisioning Your Mac For Graphic Design Department..."

    /usr/local/bin/jamf/ policy -event installchrome
    /usr/local/bin/jamf/ policy -event installoffice
    /usr/local/bin/jamf/ policy -event installzoom
    /usr/local/bin/jamf/ policy -event installslack

fi


# Updating JamfPro Inventory

/usr/local/bin/jamf recon -assetTag "$assetTag" -department "$department" -endUsername "$username"


# Creating Admin Folder in Libraries.

/bin/mkdir -p "/Library/Onicom Admin Tools"


# Generate .plist recipt file.

/usr/bin/defaults write "/Library/Onicom Admin Tools/provisionRecipt.plist" provisiondate -date $( /bin/date "+%Y-%m-%d" )
/usr/bin/defaults write "/Library/Onicom Admin Tools/provisionRecipt.plist" provisioner -string "$username"
/usr/bin/defaults write "/Library/Onicom Admin Tools/provisionRecipt.plist" department -string "$department"
/usr/bin/defaults write "/Library/Onicom Admin Tools/provisionRecipt.plist" assettag -string "$assetTag"


# Now Lastly Once all is Done Restart The Mac.

/sbin/shutdown -r now


# Set Exit Code 0

exit 0
