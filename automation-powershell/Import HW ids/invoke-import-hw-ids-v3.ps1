function Add-HardwareIDsToRegistryPol {
    param (
        [string[]]$HardwareIDs,
        [string]$RegistryPolPath = "C:\Windows\System32\GroupPolicy\Machine\registry.pol"
    )

    if (-not (Test-Path $RegistryPolPath)) {
        Write-Error "The registry.pol file was not found at the specified path: $RegistryPolPath"
        return
    }

    $keyPath = "Software\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceIDs"

    # Read the registry.pol file and convert it to a byte array
    $registryPolData = [System.IO.File]::ReadAllBytes($RegistryPolPath)

    # Parse the header
    $header = [System.Text.Encoding]::Unicode.GetString($registryPolData, 0, 14)
    if ($header -ne "PRegPolfile`0") {
        Write-Error "The provided file is not a valid registry.pol file"
        return
    }

    # Parse the existing entries
    $index = 14
    $entries = @()

    while ($index -lt $registryPolData.Length) {
        $keyPathLength = [BitConverter]::ToUInt32($registryPolData, $index)
        $index += 4

        $valueNameLength = [BitConverter]::ToUInt32($registryPolData, $index)
        $index += 4

        if ($keyPathLength -gt 0 -and $valueNameLength -gt 0) {
            $keyPathBytes = $registryPolData[$index..($index + $keyPathLength * 2 - 1)]
            $index += $keyPathLength * 2

            $valueNameBytes = $registryPolData[$index..($index + $valueNameLength * 2 - 1)]
            $index += $valueNameLength * 2

            $valueType = [BitConverter]::ToUInt32($registryPolData, $index)
            $index += 4

            $valueDataLength = [BitConverter]::ToUInt32($registryPolData, $index)
            $index += 4

            $valueDataBytes = $registryPolData[$index..($index + $valueDataLength - 1)]
            $index += $valueDataLength

            $entries += @{
                KeyPath = [System.Text.Encoding]::Unicode.GetString($keyPathBytes).TrimEnd("`0")
                ValueName = [System.Text.Encoding]::Unicode.GetString($valueNameBytes).TrimEnd("`0")
                ValueType = $valueType
                ValueData = $valueDataBytes
            }
        }
    }

    # Add the new hardware IDs
    foreach ($HardwareID in $HardwareIDs) {
        $entries += @{
            KeyPath = $keyPath
            ValueName = $HardwareID
            ValueType = 4 # REG_DWORD
            ValueData = [BitConverter]::GetBytes(1)
        }
    }

# Create a new registry.pol file with the updated entries
$newRegistryPolData = [System.Text.Encoding]::Unicode.GetBytes("PRegPolfile`0") + [BitConverter]::GetBytes(1)
foreach ($entry in $entries) {
    $keyPathBytes = [System.Text.Encoding]::Unicode.GetBytes($entry.KeyPath + "`0")
    $valueNameBytes = [System.Text.Encoding]::Unicode.GetBytes($entry.ValueName + "`0")
    $valueTypeBytes = [BitConverter]::GetBytes($entry.ValueType)
    $valueDataLengthBytes = [BitConverter]::GetBytes($entry.ValueData.Length)

    $newRegistryPolData += [BitConverter]::GetBytes($keyPathBytes.Length / 2)
    $newRegistryPolData += [BitConverter]::GetBytes($valueNameBytes.Length / 2)
    $newRegistryPolData += $keyPathBytes
    $newRegistryPolData += $valueNameBytes
    $newRegistryPolData += $valueTypeBytes
    $newRegistryPolData += $valueDataLengthBytes
    $newRegistryPolData += $entry.ValueData
}

# Backup the original registry.pol file
$backupRegistryPolPath = $RegistryPolPath + ".bak"
Copy-Item $RegistryPolPath -Destination $backupRegistryPolPath -Force

# Write the updated data to the registry.pol file
[System.IO.File]::WriteAllBytes($RegistryPolPath, $newRegistryPolData)

# Force a group policy update
gpupdate /force

# Output success message
Write-Host "Device restriction applied successfully."
