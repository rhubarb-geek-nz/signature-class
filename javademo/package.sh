#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

rm -rf build javademo.jar

mkdir build

javac Main.java -d build

jar --create --main-class nz.geek.rhubarb.signatureclass.Main --file javademo.jar -C build $(cd build ; find * -name "*.class")

jarsigner -sigfile JAVADEMO -keystore ../codesign/signature-class.pfx -storepass changeit -tsa http://timestamp.digicert.com javademo.jar codesign
