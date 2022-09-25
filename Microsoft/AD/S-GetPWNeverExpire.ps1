
get-aduser -filter * -properties Name, PasswordNeverExpires | where {
    $_.passwordNeverExpires -eq "true" } |  Select-Object DistinguishedName,Name,Enabled |
    Export-csv D:\trhg\pw_never_expires.csv -NoTypeInformation