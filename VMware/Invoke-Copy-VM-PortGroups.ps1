<#
.SYNOPSIS
    Invoke Kiosk Config
.DESCRIPTION
    Copy virtual machine portgroups from one ESX(i) host to another. This script does not copy VMKERNEL portgroups!

    1. Connet to vcenter (connect-viserver <your-server> -user <your-user> -password <your password>)
    2. Check example for syntax.
  
.EXAMPLE
    .\Copy-VM-Portgroups.ps1 <source host> <vSwitch> <destination host> <vSwitch>

    .\Copy-VM-Portgroups.ps1 host1.mydomain.no vSwitch0 host2.mydomain.no vSwitch0
.NOTES
    FileName:    Invoke-Copy-VM-PortGroups.ps1
    Author:      -
    Contact:     -
    Created:     2022-09-29
    Updated:     -
    
    Version history:
    1.0.0 - (2022-09-29) Script created
    
#>    


function CheckArgs { ##($arg0,$arg1,$arg2,$arg3)
    write-host -fore Red "Missing arguments..."
    write-host -fore Red "Usage:"
    write-host -fore Red ".\Copy_PortGroups.ps1 <source host> <vSwitch> <destination host> <vSwitch>"
    exit
}

## Check if there are submitted sufficient arguments - no quality check here...:)
if ($args.count -lt 4) { CheckArgs } ##$args[0] $args[1] $args[2] $args[3]

## Checking if arguments (0) are valid: Source host
if (!($Source_Host = get-vmhost $args[0] -erroraction SilentlyContinue)) { write-host -fore Red $args[0] "does not exists!"; exit }

## Check if arguments (1) are valid: Source virtual switch
if (!($Source_vSwitch = $Source_Host | get-virtualswitch -Name $args[1] -erroraction SilentlyContinue)) { write-host -fore Red $args[1] "does not exists!"; exit }

## Check if arguments (2) are valid: Destination host
if (!($Dest_Host = get-vmhost $args[2] -erroraction SilentlyContinue)) { write-host -fore Red $args[2] "does not exists!"; exit }

##Check if arguments (3) are valid: Destination virtual switch - if not exists, create it!
if (!($Dest_Host | get-virtualswitch -Name $args[3] -erroraction SilentlyContinue)) { 
    write-host -fore Yellow "Creating" $args[3] 
    $Dest_vSwitch = $Dest_Host | New-VirtualSwitch -Name $args[3] -Mtu $Source_vSwitch.Mtu | out-null
}

## Gathering portgroups from source host and defining vswitch on desitnation host
$Source_portgroups = $Source_Host | get-virtualswitch -Name $args[1] | get-virtualportgroup
$Dest_vSwitch = Get-VirtualSwitch -VMHost $args[2] -Name $args[3]

## Now the copying of virtual machine portgroups starts
foreach ($pgr in $Source_Portgroups) {
    if (!( $Dest_Host | Get-VirtualPortgroup -Name $pgr.Name -ErrorAction SilentlyContinue)) {
        write-host "Creating portgroup" $pgr.Name
        New-VirtualPortgroup -Name $pgr.Name -VirtualSwitch $Dest_vSwitch -VLanId $pgr.VLanId | out-null
    }
    else { 
        write-host "The portgroup" $pgr.Name "already exists." 
    }
} 