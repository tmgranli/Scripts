<#
.SYNOPSIS
    Invoke Kiosk Config
.DESCRIPTION
    This script will invoke the KIOSK Config process and prepare the device for using with an autologgon user. 
  
.EXAMPLE
    .\Invoke-UpdateDriver.ps1
.NOTES
    FileName:    Invoke-PrepareKioskConfig.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-09-20
    Updated:     2022-04-09
    
    Version history:
    1.0.0 - (2022-09-20) Script created
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
        [string]$FileName = "Driver.log",
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
Write-LogEntry -Stamp -Value "Installation started"
Write-LogEntry -Value "##################################"

#Prepare logging and error handling
clear-host
    
$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\Transcript-Log.log"
Start-Transcript $LogPS | Out-Null
    
#Needed variables
Write-host "Read variables" -Verbose -BackgroundColor Cyan -ForegroundColor Black


Try {

    #Update drivers

    New-Item -Path "c:\" -Name "temp" -ItemType "directory" -force -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "Temp folder created"

    New-Item -Path "c:\temp" -Name "wlan-drivers" -ItemType "directory" -force -Verbose  -ErrorAction Stop
    Write-LogEntry -Stamp -Value "wlan-drivers folder created"

    Copy-Item .\drivers\* -Destination C:\temp\wlan-drivers\ -Recurse -Verbose -Force -ErrorAction Stop
    Write-LogEntry -Stamp -Value  "WLAN drivers copied to staging area"

    c:\windows\sysnative\Pnputil.exe /add-driver "C:\temp\wlan-drivers\*.inf" /install > c:\temp\w500-wlandriverpnputil.txt
    Write-LogEntry -Stamp -Value "Drivers have been updated"

    #Create Detection Method  
    $RegistryPath = "HKLM:\SOFTWARE\Sarpsborg kommune\Drivers" #Pek til ønsket lokasjon i registry
    $RegistryName = "WLANDriversUpdated" #Skriv inn ønsket navn på "Value".
    $RegistryValue = "1" #Skriv inn ønsket "Data Value"

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
    $RegistryPath = "HKLM:\SOFTWARE\Sarpsborg kommune\Drivers" #Pek til ønsket lokasjon i registry
    $RegistryName = "WLANDriversUpdated" #Skriv inn ønsket navn på "Value".
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
Write-LogEntry -Stamp -Value "Installation Finished"
Write-LogEntry -Value "##################################"
    
Stop-Transcript