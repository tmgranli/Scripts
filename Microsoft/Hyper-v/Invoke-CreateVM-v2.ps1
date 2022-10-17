#Variables for VM configuration
$HostName = "*.*.no"
$SRV = "BC-W10-X64"
$RAM = 4GB
$DISK = 60GB
$NETWORK = "External"
$ISO = "D:\BootImage\LiteTouchPE_x64.iso"
$CPU = 2


#Create a new VM with specified configuration
New-VM -Name $SRV -ComputerName $HostName -MemoryStartupBytes $RAM -NewVHDPath "BC-W10-X64.VHDX" -NewVHDSizeBytes $DISK -SwitchName $NETWORK
Set-VMProcessor BC-W10-X64 -Count $CPU

#Enable VLAN ID for the VM's network adapter, this can be commented out if you don't require VLAN for your VM
Set-VMNetworkAdapterVlan -ComputerName $HostName -VMName $SRV -Access -VlanId 8

#Load boot ISO
Set-VMDvdDrive -ComputerName $HostName -VMName $SRV -Path $ISO

#Start VM
Start-VM -ComputerName $HostName -Name $SRV

#Email receiver@domain.com informing that the reference image creation has begun as scheduled
Send-MailMessage -SmtpServer "cas02.sarpsborg.com" -From "mdtadmin@sarpsborg.com" -To "trhg@sarpsborg.com" -Subject "Reference Image BC-W8.1-X64 has begun" -Body "Please monitor for an email in about 2-3 hours telling that the reference image creation process has successfully finished."


