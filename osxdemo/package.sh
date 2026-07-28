#!/bin/sh -ex
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

mkdir bin

trap "rm -rf bin" 0

cc hello.c -arch x86_64 -arch arm64 -Wall -Werror -o bin/hello

codesign --sign "Developer ID Application: $APPLE_DEVELOPER" bin/hello

pkgbuild \
	--root bin \
	--identifier nz.geek.rhubarb.signatureclass \
	--version 1.0.0 \
	--install-location /usr/local/share/signatureclass \
	--sign "Developer ID Installer: $APPLE_DEVELOPER" \
	signature-class.pkg
