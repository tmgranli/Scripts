# Define an array of hardware IDs to add to the Allow List
$hardwareIds = @(
    "USB\VID_046D&PID_C52B&MI_00\7&1EA298A&0&0000",
    "USB\VID_046D&PID_C534&MI_00\7&8F2A464&0&0000"
)

# Check if the Allow List is supported on the current version of Windows
if ([System.Environment]::OSVersion.Version -lt [Version] "10.0.15063") {
    Write-Host "The Allow List is not supported on this version of Windows."
    Exit
}

# Check if the "Prevent installation of devices not described by other policy settings" policy is enabled
$policyValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" -Name "DenyUnspecified"
if ($policyValue -eq 1) {
    Write-Host "The 'Prevent installation of devices not described by other policy settings' policy is enabled."
    #Exit
}

# Get the current Allow List
$allowList = Get-PnpDeviceProperty -KeyName "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DeviceInstall\Restrictions\AllowList" -ErrorAction SilentlyContinue

# If the Allow List is not currently set, create a new array
if ($allowList -eq $null) {
    $allowList = @()
}

# Add the new hardware IDs to the Allow List
$allowList += $hardwareIds

# Set the updated Allow List
try {
    Set-PnpDeviceProperty -KeyName "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DeviceInstall\Restrictions\AllowList" -Value $allowList -ErrorAction Stop
    Write-Host "Successfully added hardware IDs to the Allow List."
}
catch {
    Write-Host "Failed to add hardware IDs to the Allow List: $_"
}
