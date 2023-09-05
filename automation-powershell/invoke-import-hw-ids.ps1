# Define variables
$HardwareIDs = @("USB\VID_1234&PID_5678", "USB\VID_2345&PID_6789") # Replace with your hardware IDs
$LGPOPath = "C:\Path\to\LGPO.exe" # Replace with the path to LGPO.exe
$TaskName = "DeployDeviceRestriction"
$ScriptPath = "C:\LocalGPO\ApplyDeviceRestriction.ps1"

# Create a script file to apply the device restriction
$ScriptContent = @"
`$HardwareIDs = @("$($HardwareIDs -join '","')")

# Create and set the registry.pol file
`$registryContent = ''
ForEach (`$HardwareID in `$HardwareIDs) {
    `$registryContent += 'Software\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceIDs|' + "`$HardwareID" + '|1|1|0`n'
}
`$registryContent | Set-Content -Path .\registry.pol

# Apply the updated policy using LGPO.exe
& '$LGPOPath' /g .\

# Force a group policy update
gpupdate /force
"@

# Save the script content to a file
Set-Content -Path $ScriptPath -Value $ScriptContent

# Create a scheduled task to deploy the device restriction
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal
