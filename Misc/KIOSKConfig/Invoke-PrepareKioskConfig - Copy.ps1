<#
.SYNOPSIS
    Invoke Kiosk Config
.DESCRIPTION
    This script will invoke the KIOSK Config process and prepare the device for using with an autologgon user. 
  
.EXAMPLE
    .\Invoke-PrepareKioskConfig.ps1
.NOTES
    FileName:    Invoke-PrepareKioskConfig.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-03-09
    Updated:     2022-04-09
    
    Version history:
    1.0.0 - (2022-03-09) Script created
	1.0.1 - (2022-04-09) Added additional logging, methods and variables
    1.0.2 - (2022-04-09) Added PasswordGenerator to use with user creation
    1.0.3 - (2022-04-09) Fixed a problem where password wasn't converted to a secure-string
    1.0.4 - (2022-04-09) Removed "Create user" section from script. Will
    1.0.5 - (2022-09-25) Changed copy GroupPolicyUsers
    1.0.6 - (2022-09-25) Changed detectionmethod
    1.0.7 - (2022-09-25) Changed the way files are copied to GroupPolicy/GroupPolicyUsers
    1.0.8 - (2022-09-25) Addded PS lines to configure for sysnative ( https://call4cloud.nl/2021/05/the-sysnative-witch-project ).
#>    

function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}
    
#Prepare logging and error handling
clear-host
    
$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\Invoke-PrepareKioskConfig-Log.log"
Start-Transcript $LogPS | Out-Null
    
#Needed variables
Write-host "Read variables" -Verbose -BackgroundColor Cyan -ForegroundColor Black

$ConfigLog = 'C:\Sarpsborg kommune\Logs\ConfigLog.txt'
$DetectionMethod = 'C:\Sarpsborg kommune\DetectionMethod\KioskConfigCompleted_108.txt'

Try {
    Write-host "Start KIOSK configuration" -Verbose -BackgroundColor Cyan -ForegroundColor Black
    New-Item $ConfigLog -Force -Verbose -ErrorAction Stop
    
    #Create and hide config folder
    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune' -ErrorAction SilentlyContinue -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - Folder $Folder was created."
    Write-Verbose "$Folder was created successfully" -Verbose
    
    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune\Config' -ErrorAction SilentlyContinue -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - Folder 'Config' was created."
    Write-Verbose "Config folder was created successfully" -Verbose
    
    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune\DetectionMethod' -ErrorAction SilentlyContinue -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - Folder DetectionMethod was created."
    Write-Verbose "DetectionMethod folder was created successfully" -Verbose
    
    $Folder = Get-Item 'C:\Sarpsborg kommune' -Force
    $Folder.Attributes = 'Hidden'
    Add-Content $ConfigLog "$(Get-TimeStamp) - The attributes for $Folder is set to hidden."
    Write-Verbose "$Folder is scared and went in to hiding" -Verbose
    
    #Copy files 
    Copy-Item -Path ".\GroupPolicy\*" -Destination "C:\Windows\System32\GroupPolicy" -Recurse -Force -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - GroupPolicy is updated."
    Write-Verbose "GroupPolicy copied" -Verbose
       
    Copy-Item -Path ".\GroupPolicyUsers\*" -Destination "C:\Windows\System32\GroupPolicyUsers" -Recurse -Force -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - GroupPolicyUsers is updated."
    Write-Verbose "GroupPolicyUsers copied" -Verbose
 
    Copy-Item -Path ".\Startmenu\StartLayout-Kiosk.xml" -Destination 'C:\Sarpsborg kommune\Config\StartLayout-Kiosk.xml' -Force -Recurse -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - StartLayout is copied to C:\Sarpsborg kommune\Config."
    Write-Verbose "StartLayout copied" -Verbose
         
    Copy-Item -Path ".\DefaultUser\NTUSER.DAT" -Destination "C:\Users\Default\" -Force -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - NTUSER.dat have been updated."
    Write-Verbose "Modified NTUSER.dat copied" -Verbose
    
    
    #Create detectionmethod for MEM
    New-Item -Path $DetectionMethod -Force -Verbose -ErrorAction Stop #Versiosnumber needs to be updated each change
    Write-host "KIOSK configuration finish" -Verbose -BackgroundColor Cyan -ForegroundColor Black
    
    Exit 0
}
    
Catch {
        
    Write-Host "Someting went wrong, see logfile ($LogPS)  for more information" -BackgroundColor Black -ForegroundColor Red
    Write-Error "$_"
               
    Exit 1
    
}
    
Finally {
    
    Write-Host "Run this always" -BackgroundColor Yellow -ForegroundColor Black
    
}
    
$EndDTM = (Get-Date)
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
    
Stop-Transcript