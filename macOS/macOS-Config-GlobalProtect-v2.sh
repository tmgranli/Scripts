#!/bin/sh

plistBuddy='/usr/libexec/PlistBuddy'
GPplistFile='/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist3'

if [ -f ${GPplistFile} ]
then
	echo "Plist already exists..."
else
	echo "Creating Plist"
	${plistBuddy} -c "print : 'Palo Alto Networks':'GlobalProtect':'PanSetup':'Portal'" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks' dict" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect' dict" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup' dict" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'Portal' string 'portal.domene.no'" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'Prelogon' integer 0" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'certificate-store-lookup' string 'user and machine'" ${GPplistFile}
	${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'connect-method' string 'pre-logon'" ${GPplistFile}
fi
	
if [ -d "/Applications/GlobalProtect.app" ]
then
	echo "Already installed..."
	exit 0
else
	echo "Preparing..."
	#curl "https://LINK TO DOWNLOAD PAGE" > "/tmp/GlobalProtect.pkg"
	echo "Installing..."	
	#sudo installer -pkg "/tmp/GlobalProtect.pkg" -target /
	echo "Cleaning..."
	#rm "/tmp/GlobalProtect.pkg"
	exit 0
fi