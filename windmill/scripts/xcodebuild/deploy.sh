#!/bin/bash

# Requires the following variables to be set
# WINDMILL_BASE_URL
# ACCOUNT
WINDMILL_ROOT="$HOME/.windmill"

set -e

PROJECT_NAME=$1
ACCOUNT=$2
WINDMILL_BASE_URL=$3

BINARY_LENGTH=$(ls -alF build/$PROJECT_NAME.ipa | cut -d ' ' -f 8)

echo "$WINDMILL_BASE_URL/account/$ACCOUNT/windmill"

curl -i -H "binary-length: $BINARY_LENGTH" -F "ipa=@build/$PROJECT_NAME.ipa" -F "plist=@build/manifest.plist" "$WINDMILL_BASE_URL/account/$ACCOUNT/windmill"