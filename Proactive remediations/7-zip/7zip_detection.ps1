$vulnerability = "C:\Program Files\7-Zip\7-zip.chm"
$vulnerability_exists = Test-Path -Path $vulnerability 

if (!$vulnerability_exists) {
	Write-Host "All good, $vulnerability not found. "
	exit 0
}else{
	Write-Host "Vulnerable file <$vulnerability> detected."
	Exit 1
}