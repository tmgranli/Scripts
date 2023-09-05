function New-ChromeUrlShortcut {
    param (
        [string]$Url,
        [string]$ShortcutPath
    )
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
    
    # Set the Google Chrome path
    $ChromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path $ChromePath)) {
        $ChromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
    }
    
    $Shortcut.TargetPath = $ChromePath
    $Shortcut.Arguments = $Url
    $Shortcut.IconLocation = $ChromePath # You can change the icon by providing a different file and index
    $Shortcut.Save()
}

# Set the URL and shortcut path
$Url = "https://www.vg.no"
$ShortcutPath = "$env:USERPROFILE\Desktop\Example Website.lnk"

# Create the Chrome URL shortcut
New-ChromeUrlShortcut -Url $Url -ShortcutPath $ShortcutPath
