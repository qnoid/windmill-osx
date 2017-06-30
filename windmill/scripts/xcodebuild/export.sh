#!/bin/bash
set -e

PROJECT_NAME=$1
RESOURCES_ROOT=$2


xcodebuild -exportArchive -archivePath build/$PROJECT_NAME.xcarchive -exportOptionsPlist $RESOURCES_ROOT/exportOptions.plist -exportPath build
