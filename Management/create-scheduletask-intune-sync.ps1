<#
.SYNOPSIS
    
.DESCRIPTION
This script Checks if TaskSchedule exist, if not exist create. 
  
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
    1.0.1 - (2023-01-16) Added logging, if/else/try/catch logic

#>    
#Function WriteLog


function Write-LogEntry {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

$Logfile = "C:\TollTest\Logs\create-scheduletask-intune-sync.log"
$TranscriptLogFile = "C:\TollTest\Logs\create-scheduletask-intune-sync-transcript.log"


Start-Transcript -Append $TranscriptLogFile

#Check if task exist before 
$taskName = "Toll - Restart IntuneManagementExtension service at user log on"
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }

Write-LogEntry "Check if $taskname exist"


if ($taskExists ) {

    Write-LogEntry "Task $taskname already exists, exiting"
    Write-Host "Task Schedule: $taskname already exists, exiting."     -BackgroundColor Cyan -ForegroundColor Black
    Write-Host "Task Schedule: $taskname already exists, exiting.."    -BackgroundColor Cyan -ForegroundColor Black
    Write-Host "Task Schedule: $taskname already exists, exiting..."   -BackgroundColor Cyan -ForegroundColor Black
    Write-Host "Task Schedule: $taskname already exists, exiting...."  -BackgroundColor Cyan -ForegroundColor Black
    Write-Host "Task Schedule: $taskname already exists, exiting....." -BackgroundColor Cyan -ForegroundColor Black

    Exit 2
     
}
else {
    

    Try {
        ## Variables
        Write-LogEntry "Creating variables"    
        Write-Host "Creating variables" -BackgroundColor Cyan -ForegroundColor Black
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "invoke-command -scriptblock {Get-ScheduledTask | ?{$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask}"
        $Setting = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -StartWhenAvailable -DontStopIfGoingOnBatteries
        $Task = New-ScheduledTask -Trigger $Trigger -Action $Action -Settings $Setting -Description "Triggers restart of Intune extension on log on"
        $Taskname = "Toll - Restart IntuneManagementExtension service at user log on"
        Write-LogEntry "Variables created"
        Write-Host "Variables created" -BackgroundColor Cyan -ForegroundColor Black

        ## Create/Register Scheduled Task
        Write-LogEntry "Create ScheduleTask $taskname"    
        Write-Host "Create ScheduleTask $taskname"
        Register-ScheduledTask -TaskPath \Toll\ -TaskName $Taskname -InputObject $Task -User "NT AUTHORITY\SYSTEM" -Verbose
        Write-LogEntry "$taskname created"    
        Write-Host "$taskname created"    



        ## Variables for Detection Method  
        $RegistryPath = "HKLM:\SOFTWARE\Toll\Script\"
        $RegistryName = "create-scheduletask-intune-sync"
        $RegistryValue = "1" 
        $RegistryPathExist = Get-Item $RegistryPath | Select-Object Name 


        if ($RegistryPathExist) {

            Write-LogEntry "$RegistryPathExist exist"
            Write-Host do "$RegistryPathExist exist."     -BackgroundColor Cyan -ForegroundColor Black
            Write-Host do "$RegistryPathExist exist.."    -BackgroundColor Cyan -ForegroundColor Black
            Write-Host do "$RegistryPathExist exist..."   -BackgroundColor Cyan -ForegroundColor Black
            Write-Host do "$RegistryPathExist exist...."  -BackgroundColor Cyan -ForegroundColor Black
            Write-Host do "$RegistryPathExist exist....." -BackgroundColor Cyan -ForegroundColor Black

        }
        else {
            ## Create registry path for Detection Method  

            New-Item -Path $RegistryPath -ErrorAction SilentlyContinue -Verbose -Force
            Write-Host "Scheduletask Created successful with RegistryValue = $RegistryValue"
        }     
        ## Create ItemProperty for detection method
        New-ItemProperty    -Path $RegistryPath `
            -Name $RegistryName `
            -Value $RegistryValue `
            -PropertyType String `
            -Force `
            -Verbose | Out-Null

        Get-ItemProperty $RegistryPath | Select-Object $RegistryName -Verbose

        Write-LogEntry "Scheduletask Created successful with RegistryValue = $RegistryValue"
        Write-Host "Scheduletask Created successful with RegistryValue = $RegistryValue"


        Exit 0
    }
    Catch {

        $errMsg = $_.Exception.Message
        Write-host $errMsg -ForegroundColor RED -BackgroundColor 
        Write-Error 'Error creating schedule task'
        Write-LogEntry "There was a problem creating scheduletask, check $TranscriptLogFile for more information"
        
        Exit 1
    }
    
}

Write-LogEntry "Script Finished, exiting"
Stop-Transcript



