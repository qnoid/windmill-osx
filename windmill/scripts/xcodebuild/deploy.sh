#!/bin/bash

# Requires the following variables to be set
# WINDMILL_BASE_URL
# ACCOUNT

WINDMILL_HOME=$1
PROJECT_NAME=$2
SCHEME_NAME=$3
ACCOUNT=$4
WINDMILL_BASE_URL=$5

set -e

curl --fail --silent --show-error -F "ipa=@${WINDMILL_HOME}/${PROJECT_NAME}/export/$SCHEME_NAME.ipa" -F "plist=@${WINDMILL_HOME}/${PROJECT_NAME}/export/manifest.plist" "${WINDMILL_BASE_URL}/account/${ACCOUNT}/windmill" 2>/dev/null

## Deploy
#
#failedToConnect = 7 //"curl: (7) Failed to connect: Connection refused"

