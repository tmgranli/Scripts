$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }




if ($taskExists) {

    
Write-Host "does exist"

     
}
else {

Write-Host "Does NOT exist"

}
