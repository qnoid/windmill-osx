#!/bin/bash

# Requires the following variables to be set
# TEMPORARY_DIRECTORY_FOR_PROJECT
# SCHEME_NAME

set -e

# {URL}/{project name}/test/metadata.json
TEST_METADATA_FOR_PROJECT=$1
SCHEME_NAME=$2

DEPLOYMENT_TARGET=$(xcodebuild -showBuildSettings -scheme ${SCHEME_NAME} | awk '$1 == "IPHONEOS_DEPLOYMENT_TARGET" { print $3 }')

PARSE="import sys, json; print json.load(sys.stdin)[\"devices\"][\"iOS ${DEPLOYMENT_TARGET}\"][0][\"name\"]"

DESTINATION_NAME=$(xcrun simctl list devices --json | python -c "$PARSE")

echo '{"deployment":{"target":"'${DEPLOYMENT_TARGET}'"},"destination":{"name":"'${DESTINATION_NAME}'"}}' | python -m json.tool > "${TEST_METADATA_FOR_PROJECT}"
