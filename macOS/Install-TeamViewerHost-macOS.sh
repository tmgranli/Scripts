#!/bin/bash

cd /tmp

#Download and Install custom host

echo "Downloading and Installing custom host" 

cd /tmp

curl -L https://download.teamviewer.com/download/version_15x/CustomDesign/Install%20TeamViewerHost-id6yhy2b5.pkg -o TeamViewerHost-id6yhy2b5.pkg
        https://download.teamviewer.com/download/version_15x/TeamViewer_PKG.zip

installer -pkg TeamViewerHost-idc6yhy2b5.pkg -target /



#echo "30 seconds wait"

sleep 30



#Assignment

echo "Running the account assignment"

computername=$(hostname -s)

sudo /Applications/TeamViewerHost.app/Contents/Helpers/TeamViewer_Assignment -api-token YOURAPIKEY -alias $computername -group-id YOURGROUPID -reassign -grant-easy-access



#echo "10 seconds wait"

sleep 60