#!/bin/bash

function default_info_plist(){
INFO_PLIST=$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/Info.plist
}

function read_product_bundle_identifier_from_build_settings(){
PRODUCT_BUNDLE_IDENTIFIER=`(cd $WINDMILL_ROOT/$PROJECT_NAME; xcodebuild -showBuildSettings | grep "PRODUCT_BUNDLE_IDENTIFIER" | awk '{print $3}')`
}

set -e 

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

assert_directory_exists_at_path $DERIVED_DATA_DIR/$APPLICATION_NAME.app "Open in Xcode the '$APPLICATION_NAME' project. Under 'Product > Scheme > Manage Schemes...', Next to the scheme '$APPLICATION_NAME', check 'Shared'. Next do 'git commit -a -m '+ made $APPLICATION_NAME scheme 'Shared' && git push'"

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$APPLICATION_NAME.app
IPA=$DERIVED_DATA_DIR/$APPLICATION_NAME.ipa

cp $RESOURCES_ROOT/sample.plist $WINDMILL_ROOT/$APPLICATION_NAME.plist
PLIST=$WINDMILL_ROOT/$APPLICATION_NAME.plist

INFO_PLIST=$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/$APPLICATION_NAME-Info.plist
file_does_not_exist_at_path "$WINDMILL_ROOT/$PROJECT_NAME/$APPLICATION_NAME/$APPLICATION_NAME-Info.plist" default_info_plist

read_product_bundle_identifier_from_build_settings

echo "[windmill] PRODUCT_BUNDLE_IDENTIFIER '$PRODUCT_BUNDLE_IDENTIFIER'"

echo "[windmill] Setting bundle-identifier to: '$PRODUCT_BUNDLE_IDENTIFIER'"

/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-identifier $PRODUCT_BUNDLE_IDENTIFIER" $PLIST
/usr/libexec/PlistBuddy -c "Set items:0:metadata:title $APPLICATION_NAME" $PLIST