#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

jarsigner -verify -verbose -certs -keystore ../demoCA/trust.pfx -storepass changeit javademo.jar
