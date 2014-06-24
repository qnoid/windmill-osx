#!/bin/bash

set -e 

echo $PROJECT_NAME

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$PROJECT_NAME.app

IPA=$DERIVED_DATA_DIR/$PROJECT_NAME.ipa
PLIST=$WINDMILL_ROOT/$PROJECT_NAME.plist

. $SCRIPTS_ROOT/deploy.sh
