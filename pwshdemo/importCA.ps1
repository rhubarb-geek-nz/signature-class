# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

trap
{
	throw $_
}

$pass = ConvertTo-SecureString -String 'changeit' -AsPlainText 
$cert = Get-PfxCertificate -LiteralPath ..\demoCA\trust.pfx -Password $pass
$file = 'signature-demo.cer'

Export-Certificate -Cert $cert -FilePath $file -Type CERT

Import-Certificate -FilePath $file -CertStoreLocation 'Cert:\CurrentUser\Root'

Remove-Item -LiteralPath $file
