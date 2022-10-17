$testOutput= @()
$testnames = Get-Content "test.txt"
foreach ($name in $testnames){
  if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
   $testOutput+= "$name,Up"
   Write-Host "$Name,Up"
  }
  else{
    $testOutput+= "$name,Down"
    Write-Host "$Name,Down"
  }
}
$testOutput | Out-File "result.csv"