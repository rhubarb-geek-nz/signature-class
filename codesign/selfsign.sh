#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

SUBJECT="/emailAddress=joe@example.com/CN=signature-class"
PASS=changeit
DAYS=$( echo "365*100" | bc )
ALIAS=codesign

if test ! -f key.pem
then
	openssl genrsa -aes256 -out key.pem  -passout "pass:$PASS"
fi

grep -v "^keyUsage = " < /etc/ssl/openssl.cnf > signature-class.cnf

trap "rm signature-class.cnf" 0

openssl req -config signature-class.cnf -x509 -passin "pass:$PASS" -key key.pem -out cert.pem -days "$DAYS" -nodes -subj "$SUBJECT" -sha256 -extensions v3_req -addext "subjectKeyIdentifier = none" -addext "extendedKeyUsage = codeSigning,emailProtection"

openssl pkcs12 -export -in cert.pem -passin "pass:$PASS" -inkey key.pem -out signature-class.pfx -name "$ALIAS" -passout "pass:$PASS"

keytool -list -v --keystore signature-class.pfx -storetype PKCS12 -storepass "$PASS"
