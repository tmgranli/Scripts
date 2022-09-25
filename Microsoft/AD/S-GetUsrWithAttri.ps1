##Export user with 
#Office = 
#Department =
#to a CSV file

$OU_folder = 'PATH TO OU'
Get-ADUser -SearchBase $OU_folder -Filter * -Properties * | Where-Object {$_.Office -eq "9B" -and $_.Department -eq 'Tindlund ungdomsskole'} | Select-Object SamAccountname | Out-File C:\9b.csv