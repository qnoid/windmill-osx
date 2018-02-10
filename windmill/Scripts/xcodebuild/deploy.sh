#!/bin/bash

# Requires the following variables to be set
# ACCOUNT

SCHEME_NAME=$1
ACCOUNT=$2
WIDMILL_HOME=$3
EXPORT_DIRECTORY_FOR_PROJECT=$4
WINDMILL_BASE_URL=$5

set -e

curl --fail --silent --show-error -F "ipa=@${EXPORT_DIRECTORY_FOR_PROJECT}/$SCHEME_NAME.ipa" -F "plist=@${EXPORT_DIRECTORY_FOR_PROJECT}/manifest.plist" "${WINDMILL_BASE_URL}/account/${ACCOUNT}/windmill" 2>/dev/null

## Deploy
#
#failedToConnect = 7 //"curl: (7) Failed to connect: Connection refused"

