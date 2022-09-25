$Computers = "E:\_Script\Active Directory\DeleteComputers\DeleteADComputers.txt"

ForEach ($Computer in (Get-Content $Computers))
{   Try {
        Get-ADComputer $Computer | Remove-ADObject -Recursive -WhatIf -Verbose
        Add-Content "E:\_Script\Active Directory\DeleteComputers\Log_DeleteADComputers.log" -Value "$Computer removed" -Force
        #Get-Content C:\scripts\computersfordeletion.txt | % { Get-ADComputer -Filter { Name -eq $_ } } | Remove-ADObject -Recursive

    }
    Catch {
        Add-Content "E:\_Script\Active Directory\DeleteComputers\Log_DeleteADComputers.log" -Value "$Computer not found because $($Error[0])"
    }
}