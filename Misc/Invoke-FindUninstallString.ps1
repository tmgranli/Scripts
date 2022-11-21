$App = "Microsoft Office Professional Plus 2016"

#View Programs by name
#x86
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property DisplayName, UninstallString, QuietUninstallString 
#x64
Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property DisplayName, UninstallString, QuietUninstallString

#uninstall String
#x86
$uninstall = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property UninstallString
#64
$uninstall = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property UninstallString 

#Quiet Uninstall String if exsist
#x86
$uninstall = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property QuietUninstallString
#64
$uninstall = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*$App*"} | Select-Object -Property QuietUninstallString 