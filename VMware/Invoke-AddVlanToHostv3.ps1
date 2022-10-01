# AddVlan.ps1
#
# A script to automatically add a VLAN to all hosts within a cluster.
# Requires knowledge of vCenter, Cluster-name and what vSwitch needs to be configured.
#
# CHANGELOG
# v1.0 – gos@networkoc.net – Creation of the script
# v1.1 – gos@networkoc.net – Added a section for default values which may be commented out.
#

# Initialize the PowerCLI to grant access to VMware CMDlets
& “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”

# Disclaimer – “You are on your own”
write-host “IMPORTANT” -ForegroundColor red -BackgroundColor Black
write-host “This script is meant to be used by professional users only.” -ForegroundColor red -BackgroundColor white
write-host “This script does NOT sanitize input – so do not write anything wrong now. ,)” -ForegroundColor red -BackgroundColor white
write-host “USE AT OWN RISK.” -ForegroundColor red -BackgroundColor White

# Get inputs from user
$vCenter = Read-Host -Prompt ‘Input your vCenter server here’
$cluster = Read-Host -Prompt ‘Input your cluster here’
$switch = Read-Host -Prompt ‘Input your vSwitch here (e.g. vSwitch1)’
$vlanname = Read-Host -Prompt ‘Input the new VLAN name here’
$vlanid = Read-Host -Prompt ‘Input the new VLAN ID here’

# Get inputs from user, with default values
#
# Uncomment this section and comment out “get inputs from user” above
# if you would like to use default values
#
# $vCenter = Read-Host -Prompt ‘Input your vCenter server here (Press enter for vcenter01.localnetwork.local)’
# $cluster = Read-Host -Prompt ‘Input your cluster here (Press enter for datacenter01)’
# $switch = Read-Host -Prompt ‘Input your vSwitch here (Press enter for vSwitch1)’
# $vlanname = Read-Host -Prompt ‘Input the new VLAN name here’
# $vlanid = Read-Host -Prompt ‘Input the new VLAN ID here’
#
# Assign default values to the field if no user input was given
# If(-not($vCenter)){$vCenter = “vcenter01.localnetwork.local”}
# If(-not($cluster)){$cluster = “datacenter01”}
# If(-not($switch)){ $switch = “vswitch1”}

# Connect to vCenter
Connect-VIServer $vCenter

# Get the hosts of cluster with the corresponding vSwitch-name and create Virtual Port Groups
get-cluster -name $cluster | Get-VMHost | Get-VirtualSwitch -name $switch | New-VirtualPortGroup -Name $vlanname -VLanId $vlanid