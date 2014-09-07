#!/bin/bash

set -e

echo "[windmill] $IPA"
echo "[windmill] $PLIST"

LOCATION=`curl -i -H "Windmill-Name: $PROJECT_NAME" -H "Windmill-Identifier: $CFBundleIdentifier" -F "ipa=@$IPA" -F "plist=@$PLIST" http://localhost:8080/windmill/rest/windmill/$USER | grep ^Location | awk '{print $2}'`
echo "[windmill] Upload done: $LOCATION"