#!/bin/bash

# Requires the following variables to be set
# SCHEME
# CONFIGURATION
set -e

WIDMILL_HOME=$1
PROJECT_NAME=$2
SCHEME=$3
CONFIGURATION=$4

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} clean build -derivedDataPath ${WIDMILL_HOME}/${PROJECT_NAME}/build

#STATUS=$?

# Cases
## 65
### xcodebuild: error: The project named "windmill" does not contain a scheme named "windmill-ios". The "-list" option can be used to find the names of the schemes in the project.
### "The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor."

#if [ $STATUS -eq 65 ]; then
#PROJECT_NAME=`xcodebuild -list | awk '/Schemes/ { getline; print }' | xargs echo`
#fi

#xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build
