# signature-class
Signing code and packages according to different platforms

## Introduction
The purpose of this project is to document the different concepts, tools and procedures to sign packages for different platforms.

## Public and private keys
Signatures generally depend on the publisher having a private key and signing a package. They share the public keys so clients can verify the signature. How you know that the public key that you have is the correct one is a major part of the game,

## X509, PKCS12, DER and PEM
Many signatures depend on X509 certificates. The public key is encoded within the certificate and the certificate must be signed by that key. X509 have both the subject and the issuer, if they are the same it is a self-signed certificate. If the issuer is different then there will be a chain of certification authorities until you get to a self-signed root certificate. Trusting any parent certificate normally implies trusting a certificate issued and signed by them, hence chain of trust.

### X509
An X509 certificate is a signed certficate with a public key and various attributes to verify its purpose and validity.

### PKCS12
This is a container for certificates and keys. The keys will be password protected. A common example of this form is the Java Key Store.

### DER format
This is an ASN.1 encoding of data in a binary form.

### PEM format
This is an ASCII representation where the DER data is encoded using Base64 and enclosed within a header and footer. Multiple certificates can be concatenated as long as they maintain their delimiters.

## PGP or GPG
GPG is also commonly used for verification of software signatures.

## Common Tools
Some commin tools will be used.

### OpenSSL
OpenSSL is a very powerful low-level tool for performing cryptographic operations. While it is powerfulm, it is also terse and unforgiving.

### Java's keytool
Java's keytool is a very powerful tool that uses the cryptography provided by the Java runtime. Other cryptographic providers that work with Java can also be used within keytool.

### GPG/GPG2
The GNU PGP tools are available for Linux and other platforms.

## Creating a code-signing certificate
While you can buy a code-signing certificate, and you would need one for signing drivers and other software that would be accepted by Microsoft without challenge, it is worth going through the process of looking at a code-signing certificate, its various attributes and how to create one. A code signing certificate by itself may not be sufficient and you may need it signed by a CA.

Use [demoCA.sh](demoCA.sh) to create a CA. This will create a PKCS12 store called `trust.pfx` with the CA certificate in it.

Use [selfsign.sh](codesign/selfsign.sh) to create a self-signed code-signing certificate.

Use [casign.sh](codesign/casign.sh) to sign the code-signing certificate with the CA.

## Platforms

Various commons platforms are discussed.

### Windows
The various assets that support code-signing include;
* executables (exe, dll)
* PowerShell scripts (ps1)
* drivers, INF files,
* MSI, MSIX and APPX packages
* etc

The [demo.ps1](pwshdemo/demo.ps1) demonstrates signing a PowerShell script with [Set-AuthenticodeSignature](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-authenticodesignature). If the CA is trusted by adding it to the local machine's certificate manager then [Get-AuthenticodeSignature](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-authenticodesignature) will work cleanly without error.

The [Makefile](windemo/Makefile) shows compiling a native program and signing it with [signtool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool).

### Debian
Focus will be on `deb` packages and `apt` repositories.
Recent versions of [debsig-verify](https://manpages.debian.org/unstable/debsig-verify/debsig-verify.1.en.html) fail to validate signatures using SHA1. This [replacement](debsig-verify/debsig-verify.sh) works around this. Keys do not need to be changed. When packages are signed with the new [debsigs](https://manpages.debian.org/unstable/debsigs/debsigs.1p.en.html) tool they will get a new format signature.

### Redhat
Focus will be on `rpm` packages and `yum` repositories.
See [rpmdemo/README.md] for packaging the signing key and signing an `rpm`.

### NetBSD
Signing a package can be done with either X509 and GPG.

### OpenBSD
Packages are signed using a signature based on Ed25519.

### FreeBSD
The package repository data is signed. This contains digests that can validate packages once downloaded.

### MacOS
Mach-O binaries (executables, shared libraries, frameworks and bundles) can be signed. Packages have a dual layer of a packaging
* package is a collection of files installed at a location
* product is a collection of packages

Both packages and products can be signed.
Certificates need to be acquired from Apple by enrolling as a developer. [osxdemo/package.sh](osxdemo/package.sh) demonstrates signing an executable and a package.

### OpenWRT

### Alpine

### Java

A [Java demo](javademo/package.sh) using [jarsigner](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jarsigner.html) shows the mecahanics and demonstrates [verification](javademo/verify.sh) against the CA.