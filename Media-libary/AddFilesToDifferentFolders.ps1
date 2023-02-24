Get-ChildItem -Path $SourceFolder -Filter *.pdf |
    ForEach-Object {
        $ChildPath = Join-Path -Path $_.Name.Replace('.pdf','') -ChildPath $_.Name

        [System.IO.FileInfo]$Destination = Join-Path -Path $TargetFolder -ChildPath $ChildPath

        if( -not ( Test-Path -Path $Destination.Directory.FullName ) ){
            New-Item -ItemType Directory -Path $Destination.Directory.FullName
            }

        Copy-Item -Path $_.FullName -Destination $Destination.FullName
        }