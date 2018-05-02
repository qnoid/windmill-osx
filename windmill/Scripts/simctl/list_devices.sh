#!/bin/bash

# Requires the following variables to be set
# TEMPORARY_DIRECTORY_FOR_PROJECT

set -eo pipefail

# {URL}/{project name}/test/devices.json
DEVICES_FOR_PROJECT=$1
DEPLOYMENT_TARGET=$2
SCRIPTS_ROOT=$3

DESTINATION=$(xcrun simctl list devices --json | python "${SCRIPTS_ROOT}/python/devices.py" "${DEPLOYMENT_TARGET}" )

echo ${DESTINATION} > "${DEVICES_FOR_PROJECT}"
