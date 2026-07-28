#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

ALIAS=codesign
PASS=changeit
STORE=signature-class.pfx

keytool -certreq -alias "$ALIAS" -keystore "$STORE" -storepass "$PASS" -file "$ALIAS.csr"

CADIR=$(cd ../demoCA; pwd)

openssl x509 -req \
	-CAserial "$CADIR/serial" \
	-CA "$CADIR/cacert.pem" \
	-CAkey "$CADIR/private/cakey.pem" \
	-in "$ALIAS.csr" \
	-out "$ALIAS.pem" \
	-days 36500 \
	-passin "pass:$PASS" \
	-extfile "extensions-email.cnf" \
	-extensions v3_req

rm "$ALIAS.csr"

keytool -importcert -alias "democa" -keystore "$STORE" -storepass "$PASS" -file "$CADIR/cacert.pem" -noprompt

keytool -importcert -alias "$ALIAS" -keystore "$STORE" -storepass "$PASS" -file "$ALIAS.pem" -noprompt

rm "$ALIAS.pem" 

keytool -list -v -alias "$ALIAS" -keystore "$STORE" -storepass "$PASS"
