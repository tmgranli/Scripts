##Variabler##
$LogPath = 'C:\Windows\Temp\Office365.log'                
$
$RegistryPath = "HKLM:\SOFTWARE\Sarpsborg kommune\software" #Pek til ønsket lokasjon i registry
$RegistryName = "SoftwareIsInstalled" #Skriv inn ønsket navn på "Value".
$RegistryValue = "1" #Skriv inn ønsket "Data Value"

#Start Logging			
Start-Transcript -Path $LogPath

##Install Software##
Start-Process .\software.exe -Wait -ArgumentList '/configure O365_With_OneNote2016_x86.xml' -Verbose #Denne benyttes for .exe
Start-Process msiexec.exe -Wait -ArgumentList '/i sqlncli.msi /qb! /l*v C:\Windows\Temp\SQLCLIx64.log IACCEPTSQLNCLILICENSETERMS=YES' -Verbose #Denne benyttes for .msi / msp filer
					
## Create Detection Method for SCCM ##
New-Item -Path $RegistryPath -ErrorAction SilentlyContinue -Verbose -Force
New-ItemProperty    -Path $RegistryPath `
                    -Name $RegistryName `
                    -Value $RegistryValue `
                    -PropertyType String `
                    -Force `
                    -Verbose | Out-Null
Get-ItemProperty $RegistryPath | Select-Object $RegistryName -Verbose


#Stop Logging
Stop-Transcript