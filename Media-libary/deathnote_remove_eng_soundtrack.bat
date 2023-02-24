for %%a in (*.mkv) do "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "tada\%%~a" --audio-tracks 2 --subtitle-tracks 5 --default-track 5 - "%%~a"
pause