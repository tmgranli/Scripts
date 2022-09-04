New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC" -Name "FeatureLockDown" -Force

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name bDisableJavaScript -Value "1" -Force
 -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name bDisableJavaScript -Value "1" -Force