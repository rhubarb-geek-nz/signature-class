#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

python3 --version > /dev/null < /dev/null

readAttribute()
{
	python3 - $@ <<EOF
from sys import argv as args
from xml.etree import ElementTree as ET
tree = ET.parse(args[1])
el =  tree.getroot().find(args[2])
print(el.get(args[3]))
EOF
}

WORKDIR="/tmp/debsig-verify-$$"
NS="{https://www.debian.org/debsig/1.0/}"

mkdir "$WORKDIR"

trap "rm -rf $WORKDIR" 0

for d in $@
do
	if test ! -e "$d"
	then
		echo "debsig: failed to read archive '$d': No such file or directory"
		false
	fi

	if ar x "--output=$WORKDIR" "$d" _gpgorigin > /dev/null 2>&1
	then
		:
	else
		echo "debsig: Origin Signature check failed. This deb might not be signed."
		false
	fi

	if test ! -f "$WORKDIR/_gpgorigin"
	then
		echo "debsig: Origin Signature check failed. This deb might not be signed."
		false
	fi

	KEYID=$(gpg --list-packets "$WORKDIR/_gpgorigin" | grep "^:signature packet:" | grep keyid | sed 's/.* //')

	test -n "$KEYID"

	if test ! -d "/etc/debsig/policies/$KEYID"
	then
		echo "debsig: Could not find Origin directory for $KEYID"
		false
	fi

	POLICY=$(find "/etc/debsig/policies/$KEYID" -name "*.pol")

	if test ! -f "$POLICY"
	then
		echo "debsig: Could not find Origin directory for $KEYID"
		false
	fi

	FILE=$( readAttribute "$POLICY" "${NS}Verification/${NS}Required[@id='$KEYID'][@Type='origin']" File )

	if test -z "$FILE"
	then
		echo "debsig: Could not find Origin File for $KEYID"
		false
	fi

	FILELIST=$(ar t "$d")
	ORDERED=debian-binary

	for e in $FILELIST
	do
		case "$e" in
			control.* )
				ORDERED="$ORDERED $e"
				;;
			* )
				;;
		esac
	done

	for e in $FILELIST
	do
		case "$e" in
			data.* )
				ORDERED="$ORDERED $e"
				;;
			* )
				;;
		esac
	done

	if (
		for e in $ORDERED
		do
			ar p "$d" $e
		done
	) | gpg --verify --no-default-keyring --keyring "/usr/share/debsig/keyrings/$KEYID/$FILE" "$WORKDIR/_gpgorigin" - > /dev/null 2>&1
	then
		NAME=$( readAttribute "$POLICY" "${NS}Origin[@id='$KEYID']" Name )
		DESC=$( readAttribute "$POLICY" "${NS}Origin[@id='$KEYID']" Description )

		echo "debsig: Verified package from '$DESC' ($NAME)"
	else
		echo "debsig: Failed verification for $d."
		false
	fi

	find "$WORKDIR" -type f | xargs rm
done
