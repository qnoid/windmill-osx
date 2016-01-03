#!/bin/bash

# Requires the following variables to be set
# IPA
# PLIST
# APPLICATION_NAME
# WINDMILL_BASE_URL
# USER
# APPLICATION_NAME

set -e

echo "[windmill] $IPA"
echo "[windmill] $PLIST"

BINARY_LENGTH=$(ls -alF $IPA | cut -d ' ' -f 8)

LOCATION=$(curl -i -H "Windmill-Name: $APPLICATION_NAME" -H "Windmill-Identifier: $PRODUCT_BUNDLE_IDENTIFIER" -H "binary-length: $BINARY_LENGTH" -F "ipa=@$IPA" -F "plist=@$PLIST" "$WINDMILL_BASE_URL/windmill/$USER" | awk '/^Location/ {print $2}')

if_string_is_empty "$LOCATION" exit 1

echo "[windmill] Use $LOCATION for accessing '$APPLICATION_NAME'"