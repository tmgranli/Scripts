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
#>    

# Random Password Generator

$uppercase = "ABCDEFGHKLMNOPRSTUVWXYZ".tochararray() 
$lowercase = "abcdefghiklmnoprstuvwxyz".tochararray() 
$number = "0123456789".tochararray() 
$special = "$%&/()=?}{@#*+!".tochararray() 

For ($i=0; $i -le 1; $i++) {

$password =($uppercase | Get-Random -count 3) -join ''
$password +=($lowercase | Get-Random -count 10) -join ''
$password +=($number | Get-Random -count 3) -join ''
$password +=($special | Get-Random -count 3) -join ''

$passwordarray=$password.tochararray() 
$scrambledpassword=($passwordarray | Get-Random -Count 20) -join ''
$scrambledpassword
}


function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}
    
       
#Prepare logging and error handling
clear-host
    
$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\Transcript-Log.log"
Start-Transcript $LogPS | Out-Null
    
#Needed variables
Write-host "Read variables" -Verbose -BackgroundColor Cyan -ForegroundColor Black
$username = "KIOSK"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = "KIOSK"
$ConfigLog = 'C:\Sarpsborg kommune\Logs\ConfigLog.txt'
$DetectionMethod = 'C:\Sarpsborg kommune\DetectionMethod\KioskConfigCompleted_v3.txt'


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
       
    Copy-Item -Path ".\GroupPolicyUsers\S-1-5-32-545" -Destination "C:\Windows\System32\GroupPolicyUsers" -Recurse -Force -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - GroupPolicyUsers is updated."
    Write-Verbose "GroupPolicyUsers copied" -Verbose
    
    Copy-Item -Path ".\Startmenu\StartLayout-Kiosk.xml" -Destination 'C:\Sarpsborg kommune\Config\StartLayout-Kiosk.xml' -Force -Recurse -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - StartLayout is copied to C:\Sarpsborg kommune\Config."
    Write-Verbose "StartLayout copied" -Verbose
         
    Copy-Item -Path ".\DefaultUser\NTUSER.DAT" -Destination "C:\Users\Default\" -Force -Verbose -ErrorAction Stop
    Add-Content $ConfigLog "$(Get-TimeStamp) - NTUSER.dat have been updated."
    Write-Verbose "Modified NTUSER.dat copied" -Verbose
    
    #Create local user for KIOSK
    New-LocalUser -Name "$username" -AccountNeverExpires:$true -UserMayNotChangePassword:$true -PasswordNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force $scrambledpassword) -FullName $username -Description "Local KIOSK User"
    Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user have been created."
    Write-Verbose "local $username user is created" -Verbose
         
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
    Write-Verbose "AutoAdminLogon enabled" -Verbose
    
    Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
    Write-Verbose "$DefaultUsername is set as Defaultusername" -Verbose
    
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$scrambledpassword" -type String -ErrorAction Stop -Verbose
    Write-Verbose "DefaultPassword is set" -Verbose
    
    Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user is configured for AutoLogon."
     
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