# Import the required modules
Import-Module AzureAD
Import-Module Microsoft.Graph.Intune

# Connect to Intune
Connect-Intune

# Get the group name
$groupName = "MyGroup"

# Get the list of all groups
$groups = Get-AADGroup

# Loop through the groups and check if the specified group is associated with any configuration, apps, or other stuff in Intune
ForEach ($group in $groups) {
    if ($group.DisplayName -eq $groupName) {
        # Get the list of all assigned Intune policies for the group
        $policies = Get-IntuneDeviceConfigurationPolicy | Where-Object {$_.AssignedGroups -contains $group.ObjectID}

        # Get the list of all assigned Intune apps for the group
        $apps = Get-IntuneApp | Where-Object {$_.AssignedGroups -contains $group.ObjectID}

        # If the group is associated with any configuration, apps, or other stuff in Intune, output a message
        if ($policies.Count -gt 0 -or $apps.Count -gt 0) {
            Write-Host "The group $groupName is associated with Intune policies and/or apps."
        }
    }
}
