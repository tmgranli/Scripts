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
    Created:     2022-03-09
    Updated:     2022-04-09
    
    Version history:
    1.0.0 - (2022-09-20) Script created
#>    

function Get-TimeStamp {
    
    return "[{0:HH:mm:ss}]" -f (Get-Date)
        
}
    
#Prepare logging and error handling
clear-host
    
$StartDTM = (Get-Date)
$LogPS = "C:\Sarpsborg kommune\Logs\Transcript-Log.log"
Start-Transcript $LogPS | Out-Null
    
#Needed variables
Write-host "Read variables" -Verbose -BackgroundColor Cyan -ForegroundColor Black


Try {

    #Update drivers

    New-Item -Path "c:\" -Name "temp" -ItemType "directory" -force -Verbose 
    cmd.exe /C copy /Y .\drivers "C:\Windows\System32\drivers" > c:\temp\w500-wlandrivercopy.txt 
    c:\windows\sysnative\Pnputil.exe /add-driver ".\driver\*.inf" /install > c:\temp\w500-wlandriverpnputil.txt
					
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

   
    Exit 0
}
    
Catch {
    #Error    
    Write-Host "Someting went wrong, see logfile ($LogPS)  for more information" -BackgroundColor Black -ForegroundColor Red
    Write-Error "$_"
              
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



    Exit 1
    
}
    
Finally {
    
    Write-Host "Run this always" -BackgroundColor Yellow -ForegroundColor Black
    
}
    
$EndDTM = (Get-Date)
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed TIme: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
    
Stop-Transcript