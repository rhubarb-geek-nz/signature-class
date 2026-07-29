#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

PKGNAME=rhubarb-pi-debsig-verify

cleanup()
{
	rm -rf root
}

cleanup

trap cleanup 0

VERSION="1.0.0"
DPKGARCH=all
DEPENDS="python3"
MAINTAINER="rhubarb-geek-nz@users.sourceforge.net"

mkdir -p root/DEBIAN root/usr/local/bin

cp debsig-verify.sh root/usr/local/bin/debsig-verify

SIZE=$(du -sk root | while read A B; do echo $A; done)

PACKAGE_NAME="$PKGNAME"_"$VERSION"_"$DPKGARCH".deb

(
	cat <<EOF
Package: $PKGNAME
Version: $VERSION
Architecture: $DPKGARCH
Maintainer: $MAINTAINER
Depends: $DEPENDS
Installed-Size: $SIZE
Section: admin
Priority: extra
Description: debsig-verify from https://github.com/rhubarb-geek-nz/signature-class
EOF
) > root/DEBIAN/control 

chmod -R go-w root

dpkg-deb --root-owner-group --build root "$PKGNAME"_"$VERSION"_$DPKGARCH.deb
