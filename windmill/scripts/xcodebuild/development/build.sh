#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME


PROJECT_NAME=$1
xcodebuild -scheme $PROJECT_NAME -configuration Release clean build archive -derivedDataPath build -archivePath build/$PROJECT_NAME.xcarchive