<#
.SYNOPSIS
    Remove BgInfo.
.DESCRIPTION
    This script will remove BgInfo from the device.
  
.EXAMPLE
    .\Invoke-PrepareKioskConfig.ps1
.NOTES
    FileName:    Invoke-PrepareKioskConfig.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-04-09
    Updated:     
    
    Version history:
    1.0.0 - (2022-03-09) Script created
#>  
##############
function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}

###############
#Prepare logging and error handling
clear-host
    
$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\Transcript-Log.log"
$ConfigLog = "C:\Sarpsborg kommune\Logs\Config-Log.log"
$ErrorActionPreference = 'Stop'
Start-Transcript $LogPS | Out-Null



#Needed variables
Write-host "Read variables" -Verbose -BackgroundColor Cyan -ForegroundColor Black


Try {
    Remove-Item –Path "C:\Program Files\BGInfo" –Recurse –Force –Confirm:$false -Verbose
    Write-Log -Message 'Status: BgInfo Removed from C:\Program Files' -Severity Information

    Remove-Item –Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGInfo.lnk" –Force –Confirm:$false -Verbose
    Write-Log -Message 'Status: BgInfo removed from StartupFolder' -Severity Information

    Write-Verbose "BgInfo was removed successfully" -Verbose
    
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