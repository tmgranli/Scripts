$localprograms = choco list --localonly
if ($localprograms -like "*audacity*") {
    choco upgrade audacity -y
    choco upgrade audacity-lame -y
    choco upgrade audacity-ffmpeg -y
}
Else {
    choco install audacity -y
    choco install audacity-lame -y
    choco install audacity-ffmpeg -y
}