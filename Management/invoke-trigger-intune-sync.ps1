# Trigger schedule task sync 1
Get-ScheduledTask | ?{$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask -Verbose

# Trigger schedule task sync 2
Get-Service -Name IntuneManagementExtension | Stop-Service -Verbose -ErrorAction Stop
Get-Serivce -Name IntuneManagementExtension | Start-Service -Name IntuneManagementExtension -Verbose -ErrorAction Stop


