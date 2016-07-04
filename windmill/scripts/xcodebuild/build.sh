#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME
set -e

PROJECT_NAME=$1

xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build

#STATUS=$?
#65 xcodebuild: error: The project named "windmill" does not contain a scheme named "windmill-ios". The "-list" option can be used to find the names of the schemes in the project.
#if [ $STATUS -eq 65 ]; then
#PROJECT_NAME=`xcodebuild -list | awk '/Schemes/ { getline; print }' | xargs echo`
#fi

#xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build