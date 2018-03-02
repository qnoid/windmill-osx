#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME

DEVICES_FOR_PROJECT=$1
SCHEME_NAME=$2
DERIVED_DATA_PATH_FOR_PROJECT=$3
RESULT_BUNDLE_PATH_FOR_PROJECT=$4

PARSE="import sys, json; print json.load(open(\"${DEVICES_FOR_PROJECT}\"))[\"destination\"][\"udid\"]"

DESTINATION_ID=$(python -c "$PARSE")
xcodebuild test -skipUnavailableActions -scheme "${SCHEME_NAME}" -destination "platform=iOS Simulator,id=${DESTINATION_ID}" -derivedDataPath "${DERIVED_DATA_PATH_FOR_PROJECT}" -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}"

## 66 or 70: using `test-without-building`
## > xcodebuild: error: Failed to build project helloword-no-test-target with scheme helloword-no-test-target. Reason: There is nothing to test.
