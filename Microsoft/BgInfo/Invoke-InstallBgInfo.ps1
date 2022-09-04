<#
.SYNOPSIS
    Invoke BgInfo
.DESCRIPTION
    Install BGInfo64 with custom background scheme where hostname and logged on user incl. membership (Admin|User) is shown.
    It is especially usefull when dealing with virtual test environments where different devices, users, and different Autopilot profiles are used. 
    It enhanced viability of hostname, username and available permissions of the user.
  
    Thanks to Nick Hogarth. His version can be found here: https://nhogarth.net/2018/12/14/intune-win32-app-deploying-bginfo/
    
.EXAMPLE
    .\Invoke-InstallBgInfo.ps1
.NOTES
    FileName:    Invoke-PrepareKioskConfig.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-04-09
    Updated:     
    
    Version history:
    1.0.0 - (2022-04-09) Script created

#>    
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
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
 
    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Add-Content -Path "C:\Sarpsborg kommune\Logs\Install-BgInfo.log"
 }

$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\BGInfo-TranscriptLog.log"
Start-Transcript $LogPS | Out-Null

Try {
    Write-Log -Message 'Status: Installation of BgInfo - Started' -Severity Information -Verbose
    
    New-Item –ItemType Directory –Force –Path "c:\Program Files\BGInfo" -Verbose -ErrorAction Stop
    Write-Log -Message 'Status: BgInfo folder Created' -Severity Information -Verbose

    Copy-Item –Path ".\Bginfo64.exe" –Destination "C:\Program Files\BGInfo\Bginfo64.exe" -Verbose -ErrorAction Stop
    Write-Log -Message 'Bginfo64.exe have succesfully been copied to C:\Program Files\BGInfo64' -Severity Information -Verbose

    Copy-Item –Path ".\custom_kiosk.bgi" –Destination "C:\Program Files\BGInfo\custom_kiosk.bgi" -Verbose -ErrorAction Stop
    Write-Log -Message 'custom_kiosk.bgi have succesfully been copied to C:\Program Files\BGInfo64' -Severity Information -Verbose

    Copy-Item –Path ".\MacAddress.vbs" –Destination "C:\Program Files\BGInfo\MacAddress.vbs" -Verbose -ErrorAction Stop
    Write-Log -Message 'BGInfo config file have succesfully been copied: C:\Program Files\BGInfo\custom_kiosk.bgi' -Severity Information -Verbose

    Copy-Item –Path ".\ActiveIP.vbs" –Destination "C:\Program Files\BGInfo\ActiveIP.vbs" -Verbose -ErrorAction Stop
    Write-Log -Message 'BGInfo config file have succesfully been copied: C:\Program Files\BGInfo\custom_kiosk.bgi' -Severity Information -Verbose
    
    $Shell = New-Object –ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGInfo.lnk")
    $ShortCut.TargetPath="`"C:\Program Files\BGInfo\Bginfo64.exe`""
    $ShortCut.Arguments="`"C:\Program Files\BGInfo\custom_kiosk.bgi`" /timer:0 /silent /nolicprompt"
    $ShortCut.IconLocation = "Bginfo64.exe, 0";
    $ShortCut.Save()
    Write-Log -Message 'BGInfo shortcreated under StartUp folder. If this fails bginfo will not start automatically' -Severity Information -Verbose

    Write-Log -Message 'Status: Installation of BgInfo - Finished' -Severity Information -Verbose

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