## 120 days since last logon, can be changed to any number
$stale = (Get-Date).AddDays(-180)
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $stale} | Out-GridView


# Check computers who have set machinepassword for x Days
$date = (get-date).adddays(-180)
$oupath = 'path ot ou'

#Find and move computers to targetOU
get-adcomputer -filter {passwordlastset -lt $date} -properties passwordlastset | Move-ADObject -TargetPath $oupath | Disable-ad

#Fint and deletes computers
get-adcomputer -filter {passwordlastset -lt $date} -properties passwordlastset | remove-adobject -recursive -verbose -confirm:$false -WhatIf

change









