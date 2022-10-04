Connect-MSGraph

$Autopilotprofiles = Get-AutoPilotProfile

Foreach ($Autopilotprofile in $Autopilotprofiles) {

    $Temppath = "C:\MEM\"


    if (! (Test-path $Temppath)) {

        New-Item -Path $Temppath -ItemType Directory -Force

    }

    $name = $Autopilotprofile.name
    $exportpath = $Temppath + $name + "_AutopilotConfigurationProfile.json"
    $Autopilotprofile | ConvertTo-AutopilotConfigurationJSON | Out-File $exportpath -Encoding ascii

}


