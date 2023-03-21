# Set the path to the root certificate file
$rootCertPath = "C:\path\to\root\certificate.cer"

# Set the log file path
$logFilePath = "C:\path\to\log\import_root_certificate.log"

# Initialize the log file
Add-Content -Path $logFilePath -Value "Importing root certificate: $rootCertPath"

# Check if the root certificate already exists in the Trusted Root Certification Authorities store
$cert = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=Root Certificate Name"}

if (!$cert) {
    # If the certificate doesn't exist, import it
    $cert = Import-Certificate -FilePath $rootCertPath -CertStoreLocation Cert:\LocalMachine\Root
    
    if ($cert) {
        Write-Host "Root certificate has been successfully imported to the Trusted Root Certification Authorities store."
        Add-Content -Path $logFilePath -Value "Root certificate has been successfully imported to the Trusted Root Certification Authorities store."
    } else {
        Write-Host "Failed to import root certificate."
        Add-Content -Path $logFilePath -Value "Failed to import root certificate."
    }
} else {
    Write-Host "Root certificate is already installed in the Trusted Root Certification Authorities store."
    Add-Content -Path $logFilePath -Value "Root certificate is already installed in the Trusted Root Certification Authorities store."
}
