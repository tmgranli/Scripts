$localprograms = winget list
if ($localprograms -like "*VLC*") {

    winget upgrade -h --id VideoLAN.VLC
}
Else {
    winget install -e --id VideoLAN.VLC
}