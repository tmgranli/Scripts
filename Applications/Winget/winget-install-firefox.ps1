$localprograms = winget list
if ($localprograms -like "*Mozilla Firefox*") {

    winget upgrade -h --id Mozilla.Firefox
}
Else {
    winget install -e --id Mozilla.Firefox
}


