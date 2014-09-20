#!/bin/bash

set -e

echo "[windmill] $IPA"
echo "[windmill] $PLIST"

LOCATION=$(curl -i -H "Windmill-Name: $APPLICATION_NAME" -H "Windmill-Identifier: $CFBundleIdentifier" -F "ipa=@$IPA" -F "plist=@$PLIST" $WINDMILL_BASE_URL/windmill/rest/windmill/$USER | grep ^Location | awk '{print $2}')
echo "[windmill] Use $LOCATION for accessing '$APPLICATION_NAME'"