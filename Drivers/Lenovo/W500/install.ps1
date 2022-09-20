##Variabler##
$LogPath = 'C:\Windows\Temp\W500-Driverinstall.log'                
$RegistryPath = "HKLM:\SOFTWARE\Sarpsborg kommune\Drivers" #Pek til ønsket lokasjon i registry
$RegistryName = "WLANDriversUpdated" #Skriv inn ønsket navn på "Value".
$RegistryValue = "1" #Skriv inn ønsket "Data Value"

#Start Logging			
Start-Transcript -Path $LogPath

##Update drivers##

New-Item -Path "c:\" -Name "temp" -ItemType "directory" -force
cmd.exe /C copy /Y .\drivers "C:\Windows\System32\drivers" > c:\temp\w500-wlandrivercopy.txt
c:\windows\sysnative\Pnputil.exe /add-driver ".\driver\*.inf" /install > c:\temp\w500-wlandriverpnputil.txt
					
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