#!/bin/bash

# Requires the following variables to be set
# SCHEME
# CONFIGURATION
set -e

PROJECT_NAME=$1
SCHEME=$2
CONFIGURATION=$3
BUILD_METADATA_FOR_PROJECT=$4

DEPLOYMENT_TARGET=$(xcodebuild -showBuildSettings -scheme ${SCHEME} | awk '$1 == "IPHONEOS_DEPLOYMENT_TARGET" { print $3 }')

echo '{"deployment":{"target":"'${DEPLOYMENT_TARGET}'"}}' > "${BUILD_METADATA_FOR_PROJECT}"

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} clean build-for-testing -derivedDataPath ${BUILD_DIRECTORY_FOR_PROJECT}

#STATUS=$?

# Cases
## 65
### xcodebuild: error: The project named "windmill" does not contain a scheme named "windmill-ios". The "-list" option can be used to find the names of the schemes in the project.
### "The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor."

#if [ $STATUS -eq 65 ]; then
#PROJECT_NAME=`xcodebuild -list | awk '/Schemes/ { getline; print }' | xargs echo`
#fi

#xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build
