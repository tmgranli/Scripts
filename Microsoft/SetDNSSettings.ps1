# Set the DNS server addresses
$dnsServers = "8.8.8.8"

# Set the DNS suffixes
$dnsSuffixes = "example.com"  # Add more suffixes as needed

# Get the active network adapter object
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

if ($adapter) {
    # Output the name of the active adapter for clarity
    Write-Host "Configuring active adapter: $($adapter.Name)"

    # Set the DNS server addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses $dnsServers

    # Set DNS suffixes directly without piping
    Set-DnsClientGlobalSetting -SuffixSearchList $dnsSuffixes

    Write-Host "DNS settings configured successfully for $($adapter.Name)."
} else {
    Write-Host "No active network adapter found."
}
