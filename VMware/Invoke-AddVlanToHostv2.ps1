Get-VMHost | foreach {

    $vmhost = $_

    $PortGroups = $vmhost | Get-VirtualPortGroup

    $vSwitchs = $vmhost | Get-VirtualSwitch

    $pNic = $vmhost | Get-VMHostNetworkAdapter

    $Managementinfo = $pNic | Where-Object {$_.ManagementTrafficEnabled -eq $true}

    $vMotioninfo = $pNic | Where-Object {$_.VMotionEnabled -eq $true}

    $FTinfo = $pNic | Where-Object {$_.FaultToleranceLoggingEnabled -eq $true}

   

    $vlanID = $PortGroup  | Where-Object {$_.name -eq $Managementinfo.ExtensionData.spec.Portgroup} | select-object -ExpandProperty VLanId

    foreach ($PG in $PortGroups) {

        #Management Network Info

        if ($Managementinfo.PortGroupName -eq $PG.Name) {

            $MGMTStatus = "Enabled"

            $ManagementIP = $Managementinfo | Where-Object {$_.PortGroupName -eq $PG.Name} | Select-Object -ExpandProperty IP

        }

        else {

            $MGMTStatus = "Disabled"

            $ManagementIP = $null

        }

        #vMotion Network Info

        if ($vMotioninfo.PortGroupName -eq $PG.Name) {

            $vmotionStatus = "Enabled"

            $vMotionIP = $vMotioninfo | Where-Object {$_.PortGroupName -eq $PG.Name} | Select-Object -ExpandProperty IP

        }

        else {

            $vmotionStatus = "Disabled"

            $vMotionIP = $null

        }

        #FT Network Info

        if ($FaultToleranceLoggingEnabled.PortGroupName -eq $PG.Name) {

            $FTStatus = "Enabled"

            $ftIP = $FTinfo | Where-Object {$_.PortGroupName -eq $PG.Name} | Select-Object -ExpandProperty IP

        }

        else {

            $FTStatus = "Disabled"

            $ftIP = $null

        }

        #vmKernel name

        $VMKernel = $pNic | Where-Object {$_.PortGroupName -eq $PG.Name} | Select-Object -ExpandProperty DeviceName

        $result = "" | Select-Object HostName, vSwitchName, PortGroupName, VLanID, ManagementTraffic, ManagementIP, vMotionTraffic, vMotionIP, FTTraffic, FTIP, VMKernel

        $result.HostName = $vmhost.name

        $result.vSwitchName = $PG.VirtualSwitchName

        $result.PortGroupName = $PG.Name

        $result.VLanID = $PG.VLanID

        $result.VLanID = $PG.VLanID

        $result.ManagementTraffic = $MGMTStatus

        $result.ManagementIP = $ManagementIP

        $result.vMotionTraffic = $vmotionStatus

        $result.vMotionIP = $vMotionIP

        $result.FTTraffic = $FTStatus

        $result.FTIP = $ftIP

        $result.VMKernel = $VMKernel

        $result

    }

} | Export-Csv c:\temp\data.csv 