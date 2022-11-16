Detection Script:

New-PSDrive HKU Registry HKEY_USERS | out-null
$user = get-wmiobject -Class Win32_Computersystem | select Username;
$sid = (New-Object System.Security.Principal.NTAccount($user.UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value;
$key = "HKU:\$sid\Software\Microsoft\OneDrive\Accounts\Business1"
$val = (Get-Item "HKU:\$sid\Software\Microsoft\OneDrive\Accounts\Business1");
$Timer = $val.GetValue("TimerAutoMount");

##################################
#Launch Timer Detection         #
##################################

if($Timer -ne 1)
{
    Write-Host "TimerAutoMount Needs to be changed!"
    Exit 1
}
else
{
    Write-Host "TimerAutoMount doesn't need to be changed"
    Exit 0
}
