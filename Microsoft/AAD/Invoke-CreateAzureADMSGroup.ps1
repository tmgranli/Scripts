if (Get-Module -ListAvailable -Name AzureADPreview) {
    Write-Host "AzureADPreview Module Already Installed" -ForegroundColor Green
} 
else {
    Write-Host "AzureADPreview Module Not Installed. Installing........." -ForegroundColor Red
        Install-Module -Name AzureADPreview -AllowClobber -Force
    Write-Host "AzureADPreview Module Installed" -ForegroundColor Green
}
Import-Module AzureADPreview
Connect-AzureAD


# Create a Device Specific Security Group
$IntuneGroupName = "DG_TEST_PS_Intune Devices"
$IntuneGroupMailName = "DG_TEST_PS_Intune Devices"
$IntuneGroupQuery = "(device.displayName -contains ""A420"")"


# Create Dynamic Azure Active Directory Group filtered to Devices and set to Paused
$IntuneDevices = New-AzureADMSGroup `
    -Description "$($IntuneGroupName)" `
    -DisplayName "$($IntuneGroupName)" `
    -MailEnabled $false `
    -SecurityEnabled $true `
    -MailNickname "$($IntuneGroupMailName)" `
    -GroupTypes "DynamicMembership" `
    -MembershipRule "$($IntuneGroupQuery)" `
    -MembershipRuleProcessingState "Paused" 

# Set the Dynamic Azure Active Directory Group to Sync
Set-AzureADMSGroup -Id $IntuneDevices.Id -MembershipRuleProcessingState "Paused"
