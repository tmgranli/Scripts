# Import Active Directory module
Import-Module ActiveDirectory

# Set the file path and OU path
$txtFilePath = "C:\Path\To\Your\TXTFile.txt"
$ouPath = "OU=SpecificOU,DC=YourDomain,DC=com"

# Read the text file content
$txtContent = Get-Content $txtFilePath

# Initialize log file
$logFile = "C:\Path\To\LogFile.log"
if (Test-Path $logFile) {
    Remove-Item $logFile
}
New-Item -ItemType File -Path $logFile

# Create groups
foreach ($line in $txtContent) {
    $row = $line.Split(";")
    $groupName = $row[0]
    $groupDescription = $row[1]

    try {
        # Check if the group already exists
        $group = Get-ADGroup -Filter {Name -eq $groupName}
        if ($group) {
            Add-Content -Path $logFile -Value "Group '$groupName' already exists. Skipping."
        } else {
            # Create the group
            New-ADGroup -Name $groupName -Description $groupDescription -Path $ouPath -GroupScope Global -GroupCategory Security
            Add-Content -Path $logFile -Value "Group '$groupName' created successfully."
        }
    } catch {
        Add-Content -Path $logFile -Value "Error creating group '$groupName': $($_.Exception.Message)"
    }
}

# Output log file content
Get-Content -Path $logFile

           
