### Install Zoom 5.11.8425 using winget
### Author: John Bryntze
### Date: 20th December 2022

# Find path to winget.exe

$WinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$WinGetPathExe = $WinGetResolve[-1].Path

$WinGetPath = Split-Path -Path $WinGetPathExe -Parent
set-location $WinGetPath

# Run winget.exe

.\winget.exe install -e --id Zoom.Zoom -v 5.11.8425 --scope=machine --silent --accept-package-agreements --accept-source-agreements

