<#
.SYNOPSIS
    Invoke create user script
.DESCRIPTION
    This script will create a local kiosk user with a random password and configured it for autologon.
    The password will be different everytime the script is run.

.EXAMPLE
    .\Invoke-PrepareKioskConfig.ps1
.NOTES
    FileName:    Invoke-CreateKioskUser.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-03-09
    Updated:     2022-04-09
    
    Version history:
    1.0.0 - (2022-03-09) Script created
#>    

# Random Password Generator

$uppercase = "ABCDEFGHKLMNOPRSTUVWXYZ".tochararray() 
$lowercase = "abcdefghiklmnoprstuvwxyz".tochararray() 
$number = "0123456789".tochararray() 
$special = "$%&/()=?}{@#*+!".tochararray() 

For ($i = 0; $i -le 1; $i++) {

    $password = ($uppercase | Get-Random -count 3) -join ''
    $password += ($lowercase | Get-Random -count 10) -join ''
    $password += ($number | Get-Random -count 3) -join ''
    $password += ($special | Get-Random -count 3) -join ''

    $passwordarray = $password.tochararray() 
    $scrambledpassword = ($passwordarray | Get-Random -Count 20) -join ''
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
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = "KIOSK"
$ConfigLog = 'C:\Sarpsborg kommune\Logs\UserConfigLog.txt'
$DetectionMethod = 'C:\Sarpsborg kommune\DetectionMethod\KioskUserCreated_v1.txt'

Try {

    #Create local user for KIOSK
    New-LocalUser -Name $DefaultUsername -AccountNeverExpires:$true -UserMayNotChangePassword:$true -PasswordNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force $scrambledpassword ) -FullName $DefaultUsername -Description "Local KIOSK User"
    Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user have been created." -Verbose
    Write-Verbose "User: $DefaultUsername was created" -Verbose
     
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - AutoAdminLogin is configured." -Verbose
    Write-Verbose "AutoAdminLogon enabled" -Verbose

    Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - DefaultUsername is configured." -Verbose
    Write-Verbose "$DefaultUsername is set as Defaultusername" -Verbose

    Set-ItemProperty $RegPath "DefaultPassword" -Value "$scrambledpassword" -type String -ErrorAction Stop -Verbose
    Add-Content $ConfigLog "$(Get-TimeStamp) - DefaultPassword is configured." -Verbose
    Write-Verbose "DefaultPassword is set" -Verbose

    Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user is configured for AutoLogon."
    Write-host "KIOSK configuration finish" -Verbose -BackgroundColor Cyan -ForegroundColor Black

    $DUNInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' | Select-Object DefaultUserName -Verbose -InformationAction Continue
    $DPInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' | Select-Object DefaultPassword -Verbose
    $ADLInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' | Select-Object AutoAdminLogon -Verbose
    Add-Content $ConfigLog "$DUNInfo, $DPInfo, $ADLInfo"

        
    New-Item -Path $DetectionMethod -Force -Verbose -ErrorAction Stop #Versiosnumber needs to be updated each change
    
    Exit 0
}
    
Catch {
        
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