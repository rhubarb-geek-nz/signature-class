#!/bin/sh -ex
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

SUBJECT="/CN=signature-class CA"
PASS=changeit
DAYS=$(echo "365*100" | bc)
CADIR="$(pwd)/demoCA"

test ! -d "$CADIR"

mkdir "$CADIR"

(
	set -e
	cd "$CADIR"

	mkdir certsdb certreqs crl private newcerts

	chmod 700 private

	touch index.txt

	openssl req -new -newkey rsa:2048 -passout "pass:$PASS" -keyout private/cakey.pem -out careq.pem -subj "$SUBJECT"
)

openssl ca -batch -policy policy_anything -create_serial -out "$CADIR/cacert.pem" -days "$DAYS" -keyfile "$CADIR/private/cakey.pem" -passin "pass:$PASS" -selfsign -extensions v3_ca -infiles "$CADIR/careq.pem"

keytool -importcert -keystore "$CADIR/trust.pfx" -storepass "$PASS" -file "$CADIR/cacert.pem" -alias ca -noprompt

keytool -list -keystore "$CADIR/trust.pfx" -storepass "$PASS" -v
