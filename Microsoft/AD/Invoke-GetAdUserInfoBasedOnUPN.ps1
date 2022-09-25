##Convert from UPN to samAccountName
Get-Content "D:\Ansatte\trhg\Github\Sarpsborg kommune\PowershellScripts\PowershellScripts\Active Directory\Ipads_air.txt" |
ForEach-Object { Get-ADUser -LDAPFilter "(mail=$_)" } |
Select-Object sAMAccountName |
Export-Csv "D:\Ansatte\trhg\Github\Sarpsborg kommune\PowershellScripts\PowershellScripts\Active Directory\users-output.csv" -NoTypeInformation

## Get information
$userList = import-csv "D:\Ansatte\trhg\Github\Sarpsborg kommune\PowershellScripts\PowershellScripts\Active Directory\users-output.csv"
            
ForEach($User in $userList){
     Get-ADUser -Identity $user.sAMAccountName -Properties Name, Department, Office | Select-Object Name, Department, Office | Export-CSV -Append "D:\Ansatte\trhg\Github\Sarpsborg kommune\PowershellScripts\PowershellScripts\Active Directory\Export_User_Info_Results.csv" -Encoding UTF8
}