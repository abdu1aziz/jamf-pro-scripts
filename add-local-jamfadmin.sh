

# Working Perfectly Fine (Does give you eDSPermissionError but user did get created and I was able to log in with the account and password that I set in the script)

# Createing Admin Account.
sudo /usr/local/bin/jamf createAccount -username jamfadmin -realname "JamfAdmin" -password <YourDesiredPassword> -home /var/netadmin -hiddenUser -admin -secureSSH

#Creates home folder.
mkdir /var/jamfadmin
chown -R jamfadmin /var/jamfadmin

#Makes 'jamfadmin' a local admin.
dscl . -append /Groups/admin GroupMembership jamfadmin

#Hide user.
defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool YES

#Gives SSH access to 'jamfadmin'.
dseditgroup -o edit -n /Local/Default -u ExistingAdminAccount -P ExistingAdminPassword -a jamfadmin -t user com.apple.access_ssh
