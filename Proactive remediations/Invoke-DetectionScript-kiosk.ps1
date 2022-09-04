try{
    if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Verbose -ErrorAction Stop) 
    {
        Write-Host "Success"
        exit 0
    }
    
}
catch {
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1 
}
