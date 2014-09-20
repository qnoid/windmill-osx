#!/bin/bash

function default_info_plist(){
INFO_PLIST=$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/Info.plist
}

set -e 

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

assert_directory_exists_at_path $DERIVED_DATA_DIR/$APPLICATION_NAME.app "Open in Xcode the '$APPLICATION_NAME' project under '$PROJECT_LOCAL_FOLDER'. Under 'Product > Scheme > Manage Schemes...', Next to the scheme '$APPLICATION_NAME', check 'Shared'."

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$APPLICATION_NAME.app
IPA=$DERIVED_DATA_DIR/$APPLICATION_NAME.ipa

cp $RESOURCES_ROOT/sample.plist $WINDMILL_ROOT/$APPLICATION_NAME.plist
PLIST=$WINDMILL_ROOT/$APPLICATION_NAME.plist

INFO_PLIST=$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/$APPLICATION_NAME-Info.plist
file_does_not_exist_at_path "$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/$APPLICATION_NAME-Info.plist" default_info_plist

CFBundleIdentifier=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" $INFO_PLIST`

echo "[windmill] :CFBundleIdentifier '$CFBundleIdentifier'"

CFBundleIdentifier=`echo $CFBundleIdentifier | sed s/'${PRODUCT_NAME:rfc1034identifier}'/$APPLICATION_NAME/g`
CFBundleIdentifier=`echo $CFBundleIdentifier | sed s/'$(PRODUCT_NAME:rfc1034identifier)'/$APPLICATION_NAME/g`

echo "[windmill] Setting bundle-identifier to: '$CFBundleIdentifier'"

/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-identifier $CFBundleIdentifier" $PLIST
/usr/libexec/PlistBuddy -c "Set items:0:metadata:title $APPLICATION_NAME" $PLIST

. $SCRIPTS_ROOT/deploy.sh
