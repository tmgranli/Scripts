#Step 1 
Get-AppxPackage Microsoft.DesktopAppInstaller | Select Name, PackageFullName
#Step 2
Add-AppxPackage -register "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.18.2691.0_x64__8wekyb3d8bbwe\appxmanifest.xml" -DisableDevelopmentMode
#Step 3
Restart-Computer
