### Uninstall Zoom 5.11.8425 using winget
### Author: John Bryntze
### Date: 20th December 2022
### Intune command for install : powershell.exe -executionpolicy ByPass -file .\uninstall.ps1

# Find path to winget.exe

$WinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$WinGetPathExe = $WinGetResolve[-1].Path

$WinGetPath = Split-Path -Path $WinGetPathExe -Parent
set-location $WinGetPath

# Run winget.exe to uninstall

.\winget.exe uninstall -e --id GIMP.GIMP --silent