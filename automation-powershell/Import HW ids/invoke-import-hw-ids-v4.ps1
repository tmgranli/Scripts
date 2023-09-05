# Define new hardware IDs to add
$newDeviceIDs = @("DEVICE_ID_1", "DEVICE_ID_2", "DEVICE_ID_N") # Replace with your new hardware IDs

# Get current policy settings
$currentPolicy = Get-ItemProperty -Path "HKLM:\software\Policies\Microsoft\Windows\DeviceInstall\Restrictions" -Name "AllowDeviceIDs" -ErrorAction SilentlyContinue

if ($currentPolicy) {
    # Extract current device IDs and merge with new ones
    $currentDeviceIDs = $currentPolicy.AllowDeviceIDs -split ';'
    $mergedDeviceIDs = $currentDeviceIDs + $newDeviceIDs | Select -Unique
    $deviceIDString = $mergedDeviceIDs -join ";"
} else {
    # If no current policy settings, just use the new hardware IDs
    $deviceIDString = $newDeviceIDs -join ";"
}

# Create .pol file
$polFileContent = @"
[Unicode]
Unicode=yes
[Version]
signature=`"$CHICAGO`$"
Revision=1
[PolicySettings]
Software\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceIDs=4,1,0,"$deviceIDString"
"@

$polFilePath = "DeviceIDPolicy.pol"
$polFileContent | Set-Content -Path $polFilePath -Encoding Unicode

# Import policy settings using LGPO
.\LGPO.exe /g "C:\gitrepo\scripts\automation-powershell\Import HW ids\.pol"
.\LGPO.exe /m "C:\gitrepo\scripts\automation-powershell\Import HW ids\.pol\DeviceIDPolicy.pol"

.\lgpo.exe /parse /m "C:\gitrepo\scripts\automation-powershell\Import HW ids\.pol\Registry.pol" > "C:\gitrepo\scripts\automation-powershell\Import HW ids\.pol\Registry.txt"


