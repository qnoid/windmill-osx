#!/bin/bash

# Requires the following variables to be set
# SCHEME
# CONFIGURATION

TEST_DEVICES_FOR_PROJECT=$1
SCHEME=$2
CONFIGURATION=$3
DERIVED_DATA_PATH_FOR_PROJECT=$4

PARSE="import sys, json; print json.load(open(\"${TEST_DEVICES_FOR_PROJECT}\"))[\"destination\"][\"udid\"]"

DESTINATION_ID=$(python -c "$PARSE")

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} -destination "platform=iOS Simulator,id=${DESTINATION_ID}" clean build-for-testing -derivedDataPath ${DERIVED_DATA_PATH_FOR_PROJECT}

exit_code=$?
if [ $exit_code -eq 66 ]; then
xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} -destination "platform=iOS Simulator,id=${DESTINATION_ID}" clean build -derivedDataPath ${DERIVED_DATA_PATH_FOR_PROJECT}
else
exit $exit_code
fi


#STATUS=$?

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
