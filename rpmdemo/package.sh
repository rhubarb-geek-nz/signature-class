#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

LIST=$(gpg --list-secret-keys)

if test -z "$LIST"
then
	gpg --full-generate-key
fi

KEYID=$(gpg --list-secret-keys | grep "^ " | head -1 | sed 's/.* //')
PKGNAME=signature-class-rpm-gpg-key
KEYNAME=$(echo $(gpg --list-secret-keys $KEYID | grep "^uid" | sed 's/^uid//' | sed 's/.*]//' | sed 's/(.*//'))

cleanup()
{
	rm -rf data rpm.spec rpms
}

cleanup

trap cleanup 0

RELEASE=$( echo $( git log --oneline . | wc -l ))
VERSION="1.0.0"

mkdir data
mkdir -p data/etc/pki/rpm-gpg
gpg --list-keys "$KEYNAME" > /dev/null
gpg --export -a "$KEYNAME" > "data/etc/pki/rpm-gpg/RPM-GPG-KEY-$KEYNAME"

cat > rpm.spec << EOF
Summary: RPM-GPG-KEY-$KEYNAME
Name: $PKGNAME
Version: $VERSION
Release: $RELEASE
Group: Applications/System
License: GPL
BuildArch: noarch
Prefix: /etc/pki/rpm-gpg
%description
Public key /etc/pki/rpm-gpg/RPM-GPG-KEY-$KEYNAME

%files
%defattr(-,root,root)
/etc/pki/rpm-gpg/RPM-GPG-KEY-$KEYNAME
EOF

PWD=`pwd`
rpmbuild --buildroot "$PWD/data" --define "_rpmdir $PWD/rpms" -bb "$PWD/rpm.spec"

find rpms -type f -name "*.rpm" | while read N
do
	mv "$N" .
	BN=`basename "$N"`
	rpm --addsign --define "_gpg_name $KEYID" "$BN"
done
