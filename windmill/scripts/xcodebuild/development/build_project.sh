#!/bin/bash

# Requires the following variables to be set
# PROJECT_NAME
# SCHEME_NAME


$PROJECT_NAME=$1
$SCHEME_NAME=$2

xcodebuild -project $PROJECT_NAME.xcodeproj -scheme $SCHEME_NAME -configuration Debug clean build -derivedDataPath build