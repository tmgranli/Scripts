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
    1.0.1 - (2022-04-09) Script created
    1.0.2 - (2022-04-09) Added logic to detec if user exist or needs to be created.
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
    
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = "KIOSK"
$ConfigLog = 'C:\Sarpsborg kommune\Logs\Log-KioskUserConfig.txt'
$DetectionMethod = 'C:\Sarpsborg kommune\DetectionMethod\KioskUserCreated_v1.txt'

Try {


    if (Get-LocalUser -Name 'KIOSK') {
        Write-Host 'User Found, creating new password'
        Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user already exist - Creating new password."

        Set-LocalUser -Name KIOSK -Password ( ConvertTo-SecureString -AsPlainText -Force $scrambledpassword ) -Verbose -ErrorAction Stop
        Add-Content $ConfigLog "$(Get-TimeStamp) - User: 'KIOSK' is happy with it's new passw0rd."
        Write-Verbose "User: 'KIOSK' is happy with it's new passw0rd. " -Verbose

        Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
        Add-Content $ConfigLog "$(Get-TimeStamp) - Making sure AutoAdminLogon is set to '1'."
        Write-Verbose "Making sure AutoAdminLogon is set to '1' " -Verbose

        Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
        Add-Content $ConfigLog "$(Get-TimeStamp) - Making sure $DefaultUsername is configured in registry."
        Write-Verbose "Making sure $DefaultUsername is configured in registry" -Verbose

        Set-ItemProperty $RegPath "DefaultPassword" -Value "$scrambledpassword" -type String -ErrorAction Stop -Verbose
        Add-Content $ConfigLog "$(Get-TimeStamp) - Making sure DefaultPassword is configured in registry."
        Write-Verbose "Making sure DefaultPassword key is configured in registry" -Verbose

    }
    else {

        #Create local user for KIOSK

        New-LocalUser -Name $DefaultUsername -AccountNeverExpires:$true -UserMayNotChangePassword:$true -PasswordNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force $scrambledpassword ) -FullName $DefaultUsername -Description "Local KIOSK User" -ErrorAction Stop -Verbose

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
       
        New-Item -Path $DetectionMethod -Force -Verbose -ErrorAction Stop #Versiosnumber needs to be updated each change
    } 
    Exit 0  
}
    
Catch {   
    $errMsg = $_.Exception.Message
    Write-host $errMsg
    exit 1
} 