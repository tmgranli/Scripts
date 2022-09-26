<#
.SYNOPSIS
    Invoke Kiosk Config
.DESCRIPTION
What does it do ?: 

1. Copies custom GPO to local gpo folders
2. creates kiosk user if not exist.

This script is based the following blogs:
How to create the GPO for non administrators - (Step 2): https://msendpointmgr.com/2018/10/27/building-a-shared-pc-mode-kiosk-with-microsoft-intune/ 
How to get the files to be copied correctly - (Solution 1) : https://call4cloud.nl/2021/05/the-sysnative-witch-project/ . I had a issue where the GPO files was copied to C:\Windows\SysWOW64\GroupPolicyUsers and not C:\Windows\System32\GroupPolicyUsers
Password geneator / scrambler : https://community.spiceworks.com/topic/2264947-powershell-random-password-generation


Step 1: Install Windows 1X on a virtuall or physical machine.
Step 2: Open MMC and add Local Group Policy Object Editor, when the window "Welcome to the Group Policy Wizard" shows, click "Browse" --> Users --> non-adminnistrators --> Click OK --> Add and Finish
Step 3: Configure the GPO as you like
Step 4: Copy the files from C:\Windows\System32\GroupPolicyUsers (the folder is hidden) to a the place where you have the script.
Step 5: 
 
.EXAMPLE
    .\Invoke-PrepareKioskConfig.ps1
.NOTES
    FileName:    Invoke-PrepareKioskConfig.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-03-09
    Updated:     2022-09-25
    
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
    1.0.9 - (2022-09-25) Added CreateUser, password scrambler, logging and source information.
    1.1.1 - (2022-09-26) Added different logic to create user section
    1.1.2 - (2022-09-26) Added new password generator function
    
#>    
#Functions
function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information'
    )
 
    [pscustomobject]@{
        Time     = (Get-Date -f g)
        Message  = $Message
        Severity = $Severity
    } | Add-Content -Path $LogPath
}
function Get-RandomCharacters($length, $characters) {
    $random = 10..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

#Variables
$LogTS = "C:\Sarpsborg kommune\Logs\Invoke-PrepareKioskConfig-Transcript.log"
$LogPath = "C:\Sarpsborg kommune\Logs\Invoke-PrepareKioskConfig.log"
$DetectionMethod = 'C:\Sarpsborg kommune\DetectionMethod\KioskConfigCompleted_112.txt'
$DefaultUsername = "KIOSK"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


$password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 1 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 1 -characters '1234567890'
$password += Get-RandomCharacters -length 1 -characters '!"§$%&/()=?}][{@#*+'
$password = Scramble-String $password

Start-Transcript $LogTS | Out-Null

Try {

    Write-Log -Message 'Status: KIOSK enrollment started' -Severity Information
    ######################################
    #Create and hide config folder
    ######################################

    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune' -ErrorAction SilentlyContinue -Verbose
    Write-Log -Message 'Status: "C:\Sarpsborg kommune" folder created successfully ' -Severity Information
    Write-Verbose " 'C:\Sarpsborg kommune' folder was created successfully" -Verbose
    
    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune\Config' -ErrorAction SilentlyContinue -Verbose
    Write-Log -Message 'Status: "C:\Sarpsborg kommune\Config" folder created successfully ' -Severity Information
    Write-Verbose "C:\Sarpsborg kommune\Config folder was created successfully" -Verbose
    
    New-Item -ItemType Directory -Path 'C:\Sarpsborg kommune\DetectionMethod' -ErrorAction SilentlyContinue -Verbose
    Write-Log -Message 'Status: "C:\Sarpsborg kommune\DetectionMethod" folder created successfully ' -Severity Information
    Write-Verbose "C:\Sarpsborg kommune\DetectionMethod folder was created successfully" -Verbose
    
    $Folder = Get-Item 'C:\Sarpsborg kommune' -Force
    $Folder.Attributes = 'Hidden'
    Write-Log -Message 'Status: "C:\Sarpsborg kommune\" when in to hiding successfully' -Severity Information
    Write-Verbose "$Folder is scared and went in to hiding" -Verbose
    
    #Copy files 
    Copy-Item -Path ".\GroupPolicy\*" -Destination "C:\Windows\System32\GroupPolicy" -Recurse -Force -Verbose -ErrorAction Stop
    Write-Log -Message 'Status: GroupPolicy (Machine) files copied to C:\Windows\System32\GroupPolicy ' -Severity Information
    Write-Verbose "GroupPolicy copied" -Verbose
       
    Copy-Item -Path ".\GroupPolicyUsers\*" -Destination "C:\Windows\System32\GroupPolicyUsers" -Recurse -Force -Verbose -ErrorAction Stop
    Write-Log -Message 'Status: GroupPolicy (User) files copied to C:\Windows\System32\GroupPolicyUsers ' -Severity Information
    Write-Verbose "GroupPolicyUsers copied" -Verbose
 
    Copy-Item -Path ".\Startmenu\StartLayout-Kiosk.xml" -Destination 'C:\Sarpsborg kommune\Config\StartLayout-Kiosk.xml' -Force -Recurse -Verbose -ErrorAction Stop
    Write-Log -Message 'Status: StartLayout-Kiosk.xml copied to C:\Sarpsborg kommune\Config' -Severity Information
    Write-Verbose "StartLayout copied" -Verbose
         
    Copy-Item -Path ".\DefaultUser\NTUSER.DAT" -Destination "C:\Users\Default\" -Force -Verbose -ErrorAction Stop
    Write-Log -Message 'Status: NTUSER.DAT copied to "C:\Users\Default\' -Severity Information
    Write-Verbose "Modified NTUSER.dat copied" -Verbose  


    ######################################
    #CREATE LOCAL USER
    ######################################

    $op = Get-LocalUser | where-Object Name -eq "KIOSK" | Measure-Object

    if ($op.Count -eq 1) {

        Write-Host 'User Found, creating new password'
   
        Set-LocalUser -Name 'KIOSK' -Password ( ConvertTo-SecureString -AsPlainText -Force $password ) -Verbose -ErrorAction Stop
        Write-Log -Message 'Status: KIOSK is happy with the new passw0rd' -Severity Information
        Write-Verbose "User: 'KIOSK' is happy with it's new passw0rd. " -Verbose

        Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
        Write-Verbose "Making sure AutoAdminLogon is set to '1' " -Verbose

        Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
        Write-Verbose "Making sure $DefaultUsername is configured in registry" -Verbose

        Set-ItemProperty $RegPath "DefaultPassword" -Value "$password" -type String -ErrorAction Stop -Verbose
        Write-Verbose "Making sure DefaultPassword key is configured in registry" -Verbose

    } 

    else {

        #Create local user for KIOSK
        New-LocalUser -Name $DefaultUsername -AccountNeverExpires:$true -UserMayNotChangePassword:$true -PasswordNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force $password ) -FullName $DefaultUsername -Description "Local KIOSK User" -ErrorAction Stop -Verbose
        Write-Log -Message 'Status: KIOSK User created successfully' -Severity Information
        Write-Verbose "User: $DefaultUsername was created" -Verbose
         
        Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String -ErrorAction Stop -Verbose
        Write-Log -Message 'Status: AutoAdminLogin is set to: 1' -Severity Information
        Write-Verbose "AutoAdminLogon enabled" -Verbose
    
        Set-ItemProperty $RegPath "DefaultUsername" -Value ".\$DefaultUsername" -type String  -ErrorAction Stop -Verbose
        Write-Log -Message 'Status: DefaultUserName is set to KIOSK in registry' -Severity Information
        Write-Verbose "$DefaultUsername is set as Defaultusername" -Verbose
    
        Set-ItemProperty $RegPath "DefaultPassword" -Value "$password" -type String -ErrorAction Stop -Verbose
        Write-Log -Message 'Status: DefaultPassw0rd is set in registry' -Severity Information
        Write-Verbose "DefaultPassword is set" -Verbose
    
        Write-Log -Message 'Status: KIOSK is configured for AutoLogon' -Severity Information
        Write-host "CreateUser Configuration finish" -Verbose -BackgroundColor Black -ForegroundColor Green

    }
    
       
    ######################################
    #Create detectionmethod for MEM
    ######################################
    New-Item -Path $DetectionMethod -Force -Verbose -ErrorAction Stop #Versiosnumber needs to be updated each change
    Write-Log -Message 'Status: Detection method created -Check C:\Sarpsborg kommune\DetectionMethod' -Severity Information

    Write-Log -Message 'Status: KIOSK configration completed' -Severity Information
    Write-host "KIOSK configration completed" -Verbose -BackgroundColor Cyan -ForegroundColor Black

    Exit 0  
}    
Catch {
    Write-Log -Message 'Status: Something went wrong, check log file for more information C:\Sarpsborg kommune\Logs' -Severity Error
    Write-Host "Someting went wrong, see logfile ($LogTS)  for more information" -BackgroundColor Black -ForegroundColor Red -Verbose
    Write-Error "$_"

    Exit 1
}

Stop-Transcript