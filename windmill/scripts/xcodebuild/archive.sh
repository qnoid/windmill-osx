#!/bin/bash
set -e

PROJECT_NAME=$1
RESOURCES_ROOT=$2


xcodebuild -scheme $PROJECT_NAME -configuration Release archive -derivedDataPath build -archivePath build/$PROJECT_NAME.xcarchive