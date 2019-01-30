#!/bin/bash

# Requires the following variables to be set
# TEMPORARY_DIRECTORY_FOR_PROJECT

set -eo pipefail

# {URL}/{project name}/test/devices.json
DEVICES_FOR_PROJECT=$1
DEPLOYMENT_TARGET=$2
SCRIPTS_ROOT=$3
XCODE_BUILD=$4

DESTINATION=$(xcrun simctl list devices --json | xcrun python "${SCRIPTS_ROOT}/python/${XCODE_BUILD}/devices.py" "${DEPLOYMENT_TARGET}" )

if [ "${DESTINATION}" == "None" ]; then
    exit 1
else
    echo ${DESTINATION} > "${DEVICES_FOR_PROJECT}"
fi
