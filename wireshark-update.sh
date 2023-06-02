#!/bin/bash


# Grab Version:
# curl -s "https://formulae.brew.sh/api/formula/wireshark.json" | sed -n 's/.*"stable":"\([^"]*\)".*/\1/p'

# M1 => https://2.na.dl.wireshark.org/osx/Wireshark%204.0.6%20Arm%2064.dmg
# Intel => https://2.na.dl.wireshark.org/osx/Wireshark%204.0.6%20Intel%2064.dmg

# Check OS Hardware:
# macOS_device_check=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' |cut -sd '"' -f 4 |uniq)
# echo $macOS_device_check


# Check the macOS device architecture
arch_name=$(uname -m)

if [[ "$arch_name" == "arm64" ]]; then
    # Apple Silicon architecture
    download_url=$(curl -s https://www.wireshark.org/download.html | grep -Eo "https:\/\/[^\"]+_macOS_arm64\.dmg" | head -n 1)
elif [[ "$arch_name" == "x86_64" ]]; then
    # Intel architecture
    download_url=$(curl -s https://www.wireshark.org/download.html | grep -Eo "https:\/\/[^\"]+_macOS\.dmg" | head -n 1)
else
    echo "Unsupported architecture: $arch_name"
    exit 1
fi

if [[ -z "$download_url" ]]; then
    echo "Failed to retrieve download URL."
    exit 1
fi

# Download the appropriate version
echo "Downloading the appropriate version for $arch_name..."
curl -O "$download_url"

# Mount the DMG file
echo "Mounting the DMG file..."
dmg_file=$(basename "$download_url")
hdiutil attach "$dmg_file"

# Find the Wireshark application in the mounted DMG
echo "Finding the Wireshark application..."
app_path=$(find /Volumes -iname "Wireshark*.app" -maxdepth 1 -type d)

if [[ -z "$app_path" ]]; then
    echo "Failed to find Wireshark application in the DMG."
    exit 1
fi

# Copy the Wireshark application to the Applications folder
echo "Installing Wireshark..."
cp -R "$app_path" /Applications/

# Unmount the DMG file
echo "Unmounting the DMG file..."
hdiutil detach "/Volumes/Wireshark" >/dev/null

# Cleanup the downloaded files
echo "Cleaning up..."
rm -f "$dmg_file"

echo "Wireshark installation complete."
