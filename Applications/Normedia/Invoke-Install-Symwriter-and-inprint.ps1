<#
.SYNOPSIS
    Invoke installation for inprint.
.DESCRIPTION
    This script will install Symwriter and inprint.
  
.EXAMPLE  
powershell -executionpolicy bypass -file Invoke-Install-Symwriter-and-inprint.ps1

.NOTES
    FileName:    Invoke-Install-Symwriter-and-inprint.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2022-10-25
    Updated:     2022-11-02
    
    Version history:
    1.0.0 - (2022-10-25) Script created
    1.0.1 - (2022-11-21) Added Uninstall method.
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

    #### Uninstall old version
    $App1 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit Communicate: SymWriter" }
    $App1.uninstall()

    $App2 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit English UK Speech Pack" }
    $App2.uninstall()

    $App3 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit Norsk talesyntese" }
    $App3.uninstall()

    $App4 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit Symboliserer" }
    $App4.uninstall()

    $App5 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit SymWriter Ressurser Engelsk" }
    $App5.uninstall()

    $App6 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit SymWriter Ressurser Norsk" }
    $App6.uninstall()

    $App7 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit InPrint" }
    $App7.uninstall()
    
    $App8 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit InPrint Resources NO" }
    $App8.uninstall()
    
    $App9 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Widgit Wordlist Manager" }
    $App9.uninstall()
    
    ####

    Start-Process msiexec.exe -Wait -ArgumentList '/i core.msi /qb' -Verbose -ErrorAction Stop   # Med lisensnøkkel
    Write-LogEntry -Stamp -Value "Core service for Symwriter and inPrinter has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i symwriter.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "Symwriter has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i speech_no.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "speech_no.msi has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i speech_uk.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "speech_uk has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i symwriter_resources_no.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "symwriter_resources_no has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i symwriter_resources_uk.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "symwriter_resources_uk has been successfully installed"
    
    Start-Process msiexec.exe -Wait -ArgumentList '/i inprint.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "inprint has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i inprint_resources_no.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "inprint_resources_no has been successfully installed"

    Start-Process msiexec.exe -Wait -ArgumentList '/i wordlistmanager.msi /qb! /norestart' -Verbose -ErrorAction Stop
    Write-LogEntry -Stamp -Value "wordlistmanager has been successfully installed"
    
    
    #Create Detection Method  
    $RegistryPath = "HKLM:\SOFTWARE\Sarpsborg kommune\Drivers" #Pek til ønsket lokasjon i registry
    $RegistryName = "NormediaSoftwareInstalled" #Skriv inn ønsket navn på "Value".
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
    $RegistryName = "NormediaSoftwareInstalled" #Skriv inn ønsket navn på "Value".
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