for %%a in (*.mkv) do "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "tada\%%~a" --audio-tracks 1,2 --subtitle-tracks 3 --default-track 2 --default-track 6 "%%~a"

for %%a in (*.mkv) do "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "tada\%%~a" --set flag-forced=3--audio-tracks 1,2 --subtitle-tracks 3 --default-track 2 "%%~a"