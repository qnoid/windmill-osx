#!/bin/bash

# Requires the following variables to be set
# WINDMILL_BASE_URL
# USER

set -e

PROJECT_NAME=$1
USER=$2
WINDMILL_BASE_URL=$3
(
(

BUNDLE_IDENTIFIER=`/usr/libexec/plistbuddy -c "print items:0:metadata:bundle-identifier" build/manifest.plist`

BINARY_LENGTH=$(ls -alF build/$PROJECT_NAME.ipa | cut -d ' ' -f 8)

LOCATION=$(curl -i -H "Windmill-Name: $PROJECT_NAME" -H "Windmill-Identifier: $BUNDLE_IDENTIFIER" -H "binary-length: $BINARY_LENGTH" -F "ipa=@build/$PROJECT_NAME.ipa" -F "plist=@build/manifest.plist" "$WINDMILL_BASE_URL/windmill/$USER" | awk '/^Location/ {print $2}')

# if_string_is_empty "$LOCATION" exit 1

echo "[windmill] Use $LOCATION for accessing '$PROJECT_NAME'"

) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"
) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"
