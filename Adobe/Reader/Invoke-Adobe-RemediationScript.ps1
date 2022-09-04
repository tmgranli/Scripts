New-PSDrive HKU Registry HKEY_USERS | out-null
$user = get-wmiobject -Class Win32_Computersystem | select Username;
$sid = (New-Object System.Security.Principal.NTAccount($user.UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value;
$key = "HKU:\$sid\Software\Microsoft\OneDrive\Accounts\Business1"
$val = (Get-Item "HKU:\$sid\Software\Microsoft\OneDrive\Accounts\Business1") | out-null
$reg = Get-Itemproperty -Path $key -Name TimerAutoMount -erroraction 'silentlycontinue'

##################################
#Launch timer  detection       #
##################################

if(-not($reg))
	{
		Write-Host "Registry key didn't exist, creating it now"
                New-Itemproperty -path $Key -name "TimerAutoMount" -value "1"  -PropertyType "qword" | out-null
		exit 1
	} 
else
	{
 		Write-Host "Registry key changed to 1"
		Set-ItemProperty  -path $key -name "TimerAutomount" -value "1" | out-null
		Exit 0  
	}