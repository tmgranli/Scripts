##Deletes all files with the follow .extension

$path = '\\192.168.1.125\Plex\Movies\*'
Remove-Item $path -Recurse -Include *.png
Remove-Item $path -Recurse -Include *.srt
Remove-Item $path -Recurse -Include *.nfo
Remove-Item $path -Recurse -Include *.torrent
Remove-Item $path -Recurse -Include *.sub
Remove-Item $path -Recurse -Include *.idx
Remove-Item $path -Recurse -Include *.jpg
Remove-Item $path -Recurse -Include *.sfv
Remove-Item $path -Recurse -Include *.txt




##Reports all folders with more than X files in it
cd \\192.168.1.125\Plex\Movies
Get-ChildItem | Where-Object { @(Get-ChildItem $_).count -gt 2} 