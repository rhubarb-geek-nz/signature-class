# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

trap
{
	throw $_
}

$pass = ConvertTo-SecureString -String 'changeit' -AsPlainText 
$cert = Get-PfxCertificate -LiteralPath ..\codesign\signature-class.pfx -Password $pass

'"Hello World"' | Set-Content -LiteralPath hello.ps1

Set-AuthenticodeSignature -FilePath 'hello.ps1' -Certificate $cert -IncludeChain All -HashAlgorithm SHA256 -TimestampServer 'http://timestamp.fabrikam.com/scripts/timstamper.dll'
