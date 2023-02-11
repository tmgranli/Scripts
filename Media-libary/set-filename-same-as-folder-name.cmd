@Echo OFF

FOR /D /R %%# in (*) DO (
    PUSHD "%%#"
    FOR %%@ in ("index*") DO (
        Echo Ren: ".\%%~n#\%%@" "%%~n#%%~x@"
        Ren "%%@" "%%~n#%%~x@"
    )
    POPD
)

Pause&Exit