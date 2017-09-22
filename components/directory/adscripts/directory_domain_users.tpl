Import-Module ActiveDirectory


New-ADOrganizationalUnit -Path "${domain}" -name ${org} -ProtectedFromAccidentalDeletion:$false

 
New-ADUser -Path "OU=${org},${domain}" -Name "veenak" -AccountPassword (ConvertTo-SecureString "${directory_password}" -AsPlaintext -Force) -Description "MVC AD Setup Account" -ChangePasswordAtLogon:$False -CannotChangePassword:$True -PasswordNeverExpires:$True -Enabled:$True

Add-ADGroupMember 'Domain Admins' veenak

Restart-Computer -Force