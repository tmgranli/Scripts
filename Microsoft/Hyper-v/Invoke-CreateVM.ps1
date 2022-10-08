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
    1.0.1 - (2022-09-20) Added logging and driver info for WIFI
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



#Install Pre-req
#Install-WindowsFeature -Name Hyper-V -ComputerName <computer_name> -IncludeManagementTools -Restart

New-VM -Name DC -MemoryStartupBytes 512MB -Path D:\ws2012.local
Set-VMDvdDrive -VMName DC -ControllerNumber 1 -Path "<path to ISO>"

$name = 
$Switch = 
$Memory = 4096
$CPU = 
$Path = 
$ISOPath=

New-VM -Name $name -MemoryStartupBytes $Memory -BootDevice VHD -NewVHDPath E:\VirtualMachines\WinSrv2019.vhdx -Path E:\VirtualMachines -NewVHDSizeBytes 60GB -Generation 2 -Switch $Switch
Set-VM -Name $name -ProcessorCount $CPU
Add-VMDvdDrive -VMName $name -Path $ISOPath


New-VM -Name "VM-TEST" -Path "C:\VM" -MemoryStartupBytes 4GB -NewVHDPath "C:\VM\VM-TEST\VM-TEST-C.vhdx" -NewVHDSizeBytes 30GB -Generation 2 -Switch "LAB_RDR" -BootDevice NetworkAdapter