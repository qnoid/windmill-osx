#!/bin/bash

# Requires the following variables to be set
# ACCOUNT

ACCOUNT=$1
EXPORT_IPA_FOR_PROJECT=$2
EXPORT_MANIFEST_FOR_PROJECT=$3
WINDMILL_BASE_URL=$4
LOG_FOR_PROJECT=$5

set -eo pipefail

curl --fail --silent --show-error -F "ipa=@${EXPORT_IPA_FOR_PROJECT}" -F "plist=@${EXPORT_MANIFEST_FOR_PROJECT}" "${WINDMILL_BASE_URL}/account/${ACCOUNT}/export" >> "${LOG_FOR_PROJECT}"

echo "** DEPLOY SUCCEEDED **" | tee -a "${LOG_FOR_PROJECT}"

## Deploy
#
#failedToConnect = 7 //"curl: (7) Failed to connect: Connection refused"

