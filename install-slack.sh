#!/bin/bash
# 



# Defining Variables and Paths.
DOWNLOAD_URL="https://slack.com/ssb/download-osx"

APP_NAME="Slack.app"
APP_PATH="/Applications/$APP_NAME"
APP_VERSION_KEY="CFBundleShortVersionString"

SLACK_UNZIP_IN_TMP_DIRECTORY="/tmp"
SLACK_APP_UNZIPPED_IN_TMP_DIRECTORY="/tmp/Slack.app/"

getCurrentSlackVersion=$(/usr/bin/curl -s 'https://downloads.slack-edge.com/mac_releases/releases.json' | grep -o "[0-9]\.[0-9]\.[0-9]" | tail -1)


# Checking If Slack Already Up-To-Date.
if [ -d "$APP_PATH" ]; then
    localSlackVersion=$(defaults read "$APP_PATH/Contents/Info.plist" "$APP_VERSION_KEY")
    if [ "$getCurrentSlackVersion" = "$localSlackVersion" ]; then
        printf "Slack is already up-to-date. Version: %s" "$localSlackVersion"
        exit 0
    fi
fi

# OS X major release version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [ "$osvers" -lt 7 ]; then
    # Slack Unavailable for Older Versions Of MAC OSX
    printf "Slack is not available for Mac OS X 10.6 or earlier\n"
    exit 403
elif [ "$osvers" -ge 7 ]; then
    # Download Slack for MAC OSX
    finalDownloadUrl=$(curl "$DOWNLOAD_URL" -s -L -I -o /dev/null -w '%{url_effective}')
else
    # Maybe Script Isn't Running On MAC OSX.
    printf "Unable to read OS version"
    exit 404
fi

# Extracting ZipfileName
zipName=$(printf "%s" "${finalDownloadUrl[@]}" | sed 's@.*/@@')

# Defining Path To Downloaded Copy of Slack.
slackZipPath="/tmp/$zipName"

# Removing Slack From TMP Directory (zipped version and unziped as well.)
rm -rf "$slackZipPath" "$SLACK_APP_UNZIPPED_IN_TMP_DIRECTORY"

# Retry set to 3 times, if transient problems occur 
/usr/bin/curl --retry 3 -L "$finalDownloadUrl" -o "$slackZipPath"

# Trying To Unzip The Slack again, in TMP Directory.
/usr/bin/unzip -o -q "$slackZipPath" -d "$SLACK_UNZIP_IN_TMP_DIRECTORY"

# Removing Slack Zip.
rm -rf "$slackZipPath"


# Unable to Update slack while its runing!
if pgrep 'Slack'; then
    printf "Error: Slack is currently running!\n"
    exit 409
else
    if [ -d "$APP_PATH" ]; then
        rm -rf "$APP_PATH"
    fi
    # Moving New Version of slack To Apps Directory.
    mv -f "$SLACK_APP_UNZIPPED_IN_TMP_DIRECTORY" "$APP_PATH"
    
    # Slack permissions are st*p*d.
    chown -R root:admin "$APP_PATH"
    
    # Checking Out The New Version Of Slack.
    localSlackVersion=$(defaults read "$APP_PATH/Contents/Info.plist" "$APP_VERSION_KEY")
    if [ "$getCurrentSlackVersion" = "$localSlackVersion" ]; then
        printf "Slack is now updated/installed. Version: %s" "$localSlackVersion"
        exit 0
    fi
fi