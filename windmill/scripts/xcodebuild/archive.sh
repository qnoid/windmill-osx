#!/bin/bash
set -e

SCHEME_NAME=$1
PROJECT_NAME=$2
RESOURCES_ROOT=$3


xcodebuild -scheme $SCHEME_NAME -configuration Release archive -derivedDataPath build -archivePath build/$PROJECT_NAME.xcarchive