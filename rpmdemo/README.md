# signature-class/rpmdemo

Sequence of steps

* Create a GPG key
* Package public key in an RPM
* Install the RPM
* Import the key
* Validate the RPM

Example

```
$ sudo rpm -i signature-class-rpm-gpg-key-1.0.0-1.noarch.rpm
warning: signature-class-rpm-gpg-key-1.0.0-1.noarch.rpm: Header V4 EdDSA/SHA512 Signature, key ID 4824f1b1: NOKEY
$ sudo rpm --import  /etc/pki/rpm-gpg/RPM-GPG-KEY-real-name
$ rpm --checksig signature-class-rpm-gpg-key-1.0.0-1.noarch.rpm
signature-class-rpm-gpg-key-1.0.0-1.noarch.rpm: digests signatures OK
```
