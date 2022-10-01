Connect-VIServer labvm01.local.host

get-cluster -name datacenter01 | Get-VMHost | Get-VirtualSwitch -name "vSwitch1" | New-VirtualPortGroup -Name "Srv.SecureServers" -VLanId "1337"