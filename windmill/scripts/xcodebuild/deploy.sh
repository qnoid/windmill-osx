#!/bin/bash

# Requires the following variables to be set
# WINDMILL_BASE_URL
# ACCOUNT
WINDMILL_ROOT="$HOME/.windmill"

set -e

PROJECT_NAME=$1
ACCOUNT=$2
WINDMILL_BASE_URL=$3

echo "$WINDMILL_BASE_URL/account/$ACCOUNT/windmill"

curl -i -F "ipa=@exportArchive/$PROJECT_NAME.ipa" -F "plist=@exportArchive/manifest.plist" "$WINDMILL_BASE_URL/account/$ACCOUNT/windmill"
