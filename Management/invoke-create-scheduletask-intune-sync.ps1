<#
.SYNOPSIS
    
.DESCRIPTION
    This script will create an scheduletask that triggers intune sync on user log on.
  
.EXAMPLE  
powershell -executionpolicy bypass -file invoke-create-scheduletask-intune-sync.ps1

.NOTES
    FileName:    invoke-create-scheduletask-intune-sync.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2023-01-16
    Updated:     -
    
    Version history:
    1.0.0 - (2023-01-16) Script created

#>    

function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}
function Write-LogEntry {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "schtask-intune-installation.log",
        [switch]$Stamp
    )

    #Build Log File appending System Date/Time to output
    $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
    #$Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
    $Time = "[{0:HH:mm:ss}]" -f (Get-Date)
    $Date = (Get-Date -Format "dd-MM-yyyy")

    If ($Stamp) {
        $LogText = "<$($Value)> <time=""$($Time)"" date=""$($Date)"">"
    }
    else {
        $LogText = "$($Value)"   
    }
	
    Try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
    }
    Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Write-LogEntry -Value "##################################"
Write-LogEntry -Stamp -Value "Start of script"
Write-LogEntry -Value "##################################"

#Prepare logging and error handling
clear-host
$StartDTM = (Get-Date)
$LogPS = "C:\TollTest\Logs\schtask-intune-transcript.log"
Start-Transcript $LogPS | Out-Null
    
Try {

    ## Set Trigger, Task, Settings
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Write-LogEntry -Stamp -Value "Variable "$Trigger" created"

    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "Get-ScheduledTask | ?{$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask -Verbose"
    Write-LogEntry -Stamp -Value "Variable "$Action" created"

    $Setting = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -StartWhenAvailable -DontStopIfGoingOnBatteries
    Write-LogEntry -Stamp -Value "Variable "$Setting" created"

    $Task = New-ScheduledTask -Trigger $Trigger -Action $Action -Settings $Setting -Description "Triggers restart of Intune extension on log on"
    Write-LogEntry -Stamp -Value "Variable "$Task" created"

    $Taskname = "Toll - Restart IntuneManagementExtension service at user log on"
    Write-LogEntry -Stamp -Value "Variable "$Taskname" created"
    
    
 ## Create/Register Scheduled Task
    Register-ScheduledTask -TaskPath \Toll\ -TaskName $Taskname -InputObject $Task -User "NT AUTHORITY\SYSTEM" -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "ScheduledTask $Taskname created successfully"
    
    
    #Create Detection Method  
    $RegistryPath = "HKLM:\SOFTWARE\Toll\Script"
    $RegistryName = "schtask-intune-sync"
    $RegistryValue = "1" 

    New-Item -Path $RegistryPath -ErrorAction SilentlyContinue -Verbose -Force
    New-ItemProperty    -Path $RegistryPath `
        -Name $RegistryName `
        -Value $RegistryValue `
        -PropertyType String `
        -Force `
        -Verbose | Out-Null
    Get-ItemProperty $RegistryPath | Select-Object $RegistryName -Verbose
    Write-LogEntry -Stamp -Value "Registry key for successfully update added"
   
    Exit 0
}
    
Catch {

    #Error    
    Write-Host "Someting went wrong, see logfile ($LogPS)  for more information" -BackgroundColor Black -ForegroundColor Red
    Write-Error "$_"
    Write-LogEntry -Stamp -Value "Update failed, please see ($LogPS) for more details."

              
    #Create Detection Method  
    $RegistryPath = "HKLM:\SOFTWARE\Toll\Script" #Pek til ønsket lokasjon i registry
    $RegistryName = "schtask-intune-sync" #Skriv inn ønsket navn på "Value".
    $RegistryValue = "0" #Skriv inn ønsket "Data Value"
    New-Item -Path $RegistryPath -ErrorAction SilentlyContinue -Verbose -Force
    New-ItemProperty    -Path $RegistryPath `
        -Name $RegistryName `
        -Value $RegistryValue `
        -PropertyType String `
        -Force `
        -Verbose | Out-Null
    Get-ItemProperty $RegistryPath | Select-Object $RegistryName -Verbose
    Write-LogEntry -Value "Registry key for failed update added"

    Exit 1
    
}
    
Finally {
    
    Write-Host "Run this always" -BackgroundColor Yellow -ForegroundColor Black
    
}
    
$EndDTM = (Get-Date)
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Write-LogEntry -Value "##################################"
Write-LogEntry -Stamp -Value "Script Finished"
Write-LogEntry -Value "##################################"
    
Stop-Transcript

