#!/bin/bash

set -e 

echo $PROJECT_NAME

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$PROJECT_NAME.app
IPA=$DERIVED_DATA_DIR/$PROJECT_NAME.ipa

cp $RESOURCES_ROOT/sample.plist $WINDMILL_ROOT/$PROJECT_NAME.plist
PLIST=$WINDMILL_ROOT/$PROJECT_NAME.plist

CFBundleIdentifier=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" $WINDMILL_ROOT/$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME-Info.plist`
/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-identifier com.qnoid.balance" $PLIST
/usr/libexec/PlistBuddy -c "Set items:0:metadata:title $PROJECT_NAME" $PLIST

. $SCRIPTS_ROOT/deploy.sh
