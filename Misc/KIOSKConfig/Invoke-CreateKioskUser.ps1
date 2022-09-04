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



#Create local user for KIOSK
New-LocalUser -Name "$username" -AccountNeverExpires:$true -UserMayNotChangePassword:$true -PasswordNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force $scrambledpassword ) -FullName $username -Description "Local KIOSK User"
Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user have been created."
Write-Verbose "local $username user is created" -Verbose
     
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
Write-Verbose "AutoAdminLogon enabled" -Verbose

Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
Write-Verbose "$DefaultUsername is set as Defaultusername" -Verbose

Set-ItemProperty $RegPath "DefaultPassword" -Value "$scrambledpassword" -type String -ErrorAction Stop -Verbose
Write-Verbose "DefaultPassword is set" -Verbose

Add-Content $ConfigLog "$(Get-TimeStamp) - Local 'KIOSK' user is configured for AutoLogon."
 