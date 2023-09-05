# Define variables
$HardwareIDs = @("USB\VID_1234&PID_5678", "USB\VID_2345&PID_6789") # Replace with your hardware IDs
$PolicyPath = "C:\LocalGPO\GPOBackup\DeviceInstallationRestrictions"
$TaskName = "DeployDeviceRestriction"
$ScriptPath = "C:\LocalGPO\ApplyDeviceRestriction.ps1"

# Create a script file to apply the device restriction
$ScriptContent = @"
Import-Module 'C:\LocalGPO\LocalGPO.psm1'

# Add Hardware IDs to the device restriction policy
`$HardwareIDs = @("$($HardwareIDs -join '","')")

ForEach (`$HardwareID in `$HardwareIDs) {
    Set-GPRegistryValue -Name "DeviceInstallationRestrictions" -Key "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Restrictions" -ValueName "AllowDeviceIDs" -Type MultiString -Value "`$HardwareID"
}

# Apply the updated policy
Invoke-GPUpdate
"@

# Save the script content to a file
Set-Content -Path $ScriptPath -Value $ScriptContent

# Create a scheduled task to deploy the device restriction
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal
