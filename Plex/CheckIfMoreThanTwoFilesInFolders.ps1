cd \\192.168.1.125\Plex\Movies
Get-ChildItem | Where-Object { @(Get-ChildItem $_).count -gt 2} 