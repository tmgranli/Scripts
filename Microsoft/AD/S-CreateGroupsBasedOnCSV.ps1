Import-Module ActiveDirectory
$groups = Import-Csv 'E:\_Script\Active Directory\Create Group\groups.csv'
foreach ($group in $groups) {
New-ADGroup -Name $group.name -Path "path to ou" -Description "......" -GroupCategory Security -GroupScope Global }