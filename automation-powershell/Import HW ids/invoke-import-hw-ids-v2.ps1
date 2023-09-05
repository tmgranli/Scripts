# Define variables
$HardwareIDs = @("USB\VID_1234&PID_5678", "USB\VID_2345&PID_6789") # Replace with your hardware IDs
$LGPOPath = 'C:\gitrepo\Scripts\automation-powershell\Import HW ids\LGPO.exe' # Replace with the path to LGPO.exe

# Check if LGPO.exe exists
if (-not (Test-Path $LGPOPath)) {
    Write-Error "LGPO.exe not found at the specified path: $LGPOPath"
    exit 1
}

# Function to apply the device restriction
function Add-DeviceRestriction {
    param (
        [string[]]$HardwareIDs,
        [string]$LGPOPath
    )

    # Create and set the registry.pol file
    $registryHeader = [System.Text.Encoding]::Unicode.GetBytes("PReg`n")
    $registryContent = ''

    foreach ($HardwareID in $HardwareIDs) {
        $registryContent += 'Software\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceIDs|' + $HardwareID + '|1|1|0`n'
    }
    
    $registryContentBytes = [System.Text.Encoding]::Unicode.GetBytes($registryContent)
    $fullRegistryBytes = $registryHeader + $registryContentBytes
    Set-Content -Path .\registry.pol -Value ([System.IO.Stream]::NULL) -Force
    [System.IO.File]::WriteAllBytes(".\registry.pol", $fullRegistryBytes)

    # Apply the updated policy using LGPO.exe
    Start-Process -FilePath $LGPOPath -ArgumentList "/g .\" -NoNewWindow -Wait

    # Force a group policy update
    gpupdate /force
}

# Apply device restriction with the specified hardware IDs
try {
    Apply-DeviceRestriction -HardwareIDs $HardwareIDs -LGPOPath $LGPOPath
    Write-Host "Device restriction applied successfully."
} catch {
    Write-Error "An error occurred while applying the device restriction: $_"
}
