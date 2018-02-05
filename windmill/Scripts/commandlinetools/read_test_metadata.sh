#!/bin/bash

# Requires the following variables to be set
# TEMPORARY_DIRECTORY_FOR_PROJECT
# SCHEME_NAME

set -e

# {URL}/{project name}/test/metadata.json
TEST_METADATA_FOR_PROJECT=$1
SCHEME_NAME=$2
BUILD_METADATA_FOR_PROJECT=$3

PARSE="import sys, json; print json.load(open(\"${BUILD_METADATA_FOR_PROJECT}\"))[\"deployment\"][\"target\"]"

DEPLOYMENT_TARGET=$(python -c "$PARSE")

DESTINATION=$(xcrun simctl list devices --json | python "${SCRIPTS_ROOT}/python/devices.py" "${DEPLOYMENT_TARGET}" )

echo ${DESTINATION} > "${TEST_METADATA_FOR_PROJECT}"
