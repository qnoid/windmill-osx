#!/bin/bash

# Requires the following variables to be set
# APPLICATION_NAME
# SCHEME_NAME


$PROJECT_NAME=$1
$SCHEME_NAME=$2

xcodebuild -workspace $PROJECT_NAME.xcworkspace -scheme $SCHEME_NAME -configuration Debug clean build -derivedDataPath build