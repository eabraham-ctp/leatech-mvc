## TODO - removing user creation, causing problems with using LDAP authentication
## Configures script to run once on next logon
# Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'AddUsers' -Value "c:\windows\system32\cmd.exe /c C:\scripts\directory_domain_users.bat"

# Registry path for Autologon configuration
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Autologon configuration including: username, password,domain name and times to try autologon
# Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
# Set-ItemProperty $RegPath "DefaultUsername" -Value "${directory_admin}" -type String
# Set-ItemProperty $RegPath "DefaultPassword" -Value "${directory_password}" -type String
# Set-ItemProperty $RegPath "DefaultDomainName" -Value "${net_bios}" -type String
# Set-ItemProperty $RegPath "AutoLogonCount" -Value "1" -type DWord

Write-Host "Windows Server 2012 R2 - Active Directory Installation"

Write-Host " - Installing AD-Domain-Services..."
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools

## TODO - removing forest creation, causing problems with using LDAP authentication
# Import-Module ADDSDeployment
# Write-Host " - Creating new AD-Domain-Services Forest..."
# Install-ADDSForest -CreateDNSDelegation:$False -SafeModeAdministratorPassword (ConvertTo-SecureString "${directory_password}" -AsPlaintext -Force) -DomainName ${directory_name} -DomainMode ${domain_mode} -ForestMode ${forest_mode} -DomainNetBiosName ${net_bios} -InstallDNS:$True -Confirm:$False

Write-Host " - Done.`n"
