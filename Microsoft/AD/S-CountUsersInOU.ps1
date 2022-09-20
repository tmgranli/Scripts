##Count users in a spescific OU##

(Get-ADUser -Filter * -SearchBase "PATH TO OU").Count


