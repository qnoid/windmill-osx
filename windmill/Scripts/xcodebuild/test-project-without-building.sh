#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME

PROJECT=$1
DESTINATION_ID=$2
SCHEME_NAME=$3
DERIVED_DATA_PATH_FOR_PROJECT=$4
RESULT_BUNDLE_PATH_FOR_PROJECT=$5

xcodebuild -project "${PROJECT}".xcodeproj test-without-building -scheme "${SCHEME_NAME}" -destination "platform=iOS Simulator,id=${DESTINATION_ID}" -derivedDataPath "${DERIVED_DATA_PATH_FOR_PROJECT}" -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}"

# Cases
## 65
### xcodebuild: error: The project named "windmill" does not contain a scheme named "windmill-ios". The "-list" option can be used to find the names of the schemes in the project.
### "The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor."

## 66 or 70: using `test-without-building`
## > xcodebuild: error: Failed to build project helloword-no-test-target with scheme helloword-no-test-target. Reason: There is nothing to test.

## 134
###
#     2017-06-30 21:39:20.591698+0100 xcodebuild[50470:15852836] [MT] DVTAssertions: ASSERTION FAILURE in /Library/Caches/com.apple.xbs/Sources/IDEFrameworks/IDEFrameworks-13158.29/IDEFoundation/Testing/IDETestRunSession.m:333
#     Details:  (testableSummaryFilePath) should not be nil.
