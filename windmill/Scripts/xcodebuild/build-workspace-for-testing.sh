#!/bin/bash

WORKSPACE=$1
SCHEME=$2
CONFIGURATION=$3
DESTINATION_ID=$4
DERIVED_DATA_PATH_FOR_PROJECT=$5
RESULT_BUNDLE_PATH_FOR_PROJECT=$6
LOG_FOR_PROJECT=$7

set -eo pipefail

xcodebuild -workspace "${WORKSPACE}".xcworkspace -scheme "${SCHEME}" -configuration "${CONFIGURATION}" -destination "platform=iOS Simulator,id=${DESTINATION_ID}" clean build-for-testing -derivedDataPath "${DERIVED_DATA_PATH_FOR_PROJECT}" -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}" 2>&1 | tee -a "${LOG_FOR_PROJECT}"

# Cases
## 65
### xcodebuild: error: The project named "windmill" does not contain a scheme named "windmill-ios". The "-list" option can be used to find the names of the schemes in the project.
### "The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor."

#if [ $STATUS -eq 65 ]; then
#PROJECT_NAME=`xcodebuild -list | awk '/Schemes/ { getline; print }' | xargs echo`
#fi

#xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build
## 66: using `build-for-testing`
## > xcodebuild: error: Scheme no_simulator_available is not currently configured for the build-for-testing action.
