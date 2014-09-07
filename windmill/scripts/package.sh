#!/bin/bash

set -e 

echo "[windmill] $PROJECT_NAME"

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$PROJECT_NAME.app
IPA=$DERIVED_DATA_DIR/$PROJECT_NAME.ipa

cp $RESOURCES_ROOT/sample.plist $WINDMILL_ROOT/$PROJECT_NAME.plist
PLIST=$WINDMILL_ROOT/$PROJECT_NAME.plist

CFBundleIdentifier=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" $WINDMILL_ROOT/$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME-Info.plist`

echo "[windmill] :CFBundleIdentifier '$CFBundleIdentifier'"

CFBundleIdentifier=`echo $CFBundleIdentifier | sed s/'${PRODUCT_NAME:rfc1034identifier}'/$PROJECT_NAME/g`

echo "[windmill] Setting bundle-identifier to: '$CFBundleIdentifier'"

/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-identifier $CFBundleIdentifier" $PLIST
/usr/libexec/PlistBuddy -c "Set items:0:metadata:title $PROJECT_NAME" $PLIST

. $SCRIPTS_ROOT/deploy.sh
