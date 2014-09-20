#!/bin/bash
#$1 path of clone

. $SCRIPTS_ROOT/common.sh

#functions

function xcodebuild_xcworkspace(){
xcodebuild -workspace $APPLICATION_NAME.xcworkspace -scheme $APPLICATION_NAME -configuration Release clean build -derivedDataPath build PROVISIONING_PROFILE=$mobileprovisionUUID
}

function xcodebuild_xcodeproj(){
xcodebuild -project $APPLICATION_NAME.xcodeproj -scheme $APPLICATION_NAME -configuration Release clean build -derivedDataPath build PROVISIONING_PROFILE=$mobileprovisionUUID
}

function find_xcworkspace_info(){
    echo "[windmill] [info] Using $APPLICATION_NAME.xcworkspace"
}

function find_xcworkspace()
{
echo "[windmill] [debug] [$FUNCNAME]"
APPLICATION_NAME=`(cd $WINDMILL_ROOT/$PROJECT_NAME; find . -type d -name *\.xcworkspace -maxdepth 1 | sed 's/\.\/\([a-z]*\)\.xcworkspace/\1/')`
windmill_xcodebuild=xcodebuild_xcworkspace
}

function find_xcodeproj_info(){
    echo "[windmill] [info] Using $APPLICATION_NAME.xcodeproj"
}

function find_xcodeproj()
{
echo "[windmill] [debug] [$FUNCNAME]"
APPLICATION_NAME=`(cd $WINDMILL_ROOT/$PROJECT_NAME; find . -type d -name *\.xcodeproj -maxdepth 1 | sed 's/\.\/\([a-z]*\)\.xcodeproj/\1/')`
windmill_xcodebuild=xcodebuild_xcodeproj
}

function pod_install() {
export LANG=en_US.UTF-8
(cd $WINDMILL_ROOT/$PROJECT_NAME; /Users/qnoid/.rbenv/shims/pod install)
}

#script

set -e

file_exist_at_path "$WINDMILL_ROOT/$PROJECT_NAME/Podfile" pod_install

APPLICATION_NAME=$PROJECT_NAME

directory_does_not_exist_at_path "$WINDMILL_ROOT/$PROJECT_NAME/$PROJECT_NAME.xcworkspace" find_xcworkspace

if_string_is_empty "$APPLICATION_NAME" find_xcodeproj

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROJECT_NAME.mobileprovision"

assert_file_exists_at_path "$PROVISIONING_PROFILE" "Please put an Ad Hoc Distribution Provisioning Profile at $HOME/Library/MobileDevice/Provisioning Profiles/$PROJECT_NAME.mobileprovision to enable OTA distribution"

#set -o pipefail && xcodebuild $1.xcworkspace | xcpretty -c
mobileprovisionUUID=`security cms -D -i $HOME/Library/MobileDevice/Provisioning\ Profiles/$PROJECT_NAME.mobileprovision > $WINDMILL_ROOT/$PROJECT_NAME.mobileprovision.plist; /usr/libexec/PlistBuddy -c "Print :UUID" $WINDMILL_ROOT/$PROJECT_NAME.mobileprovision.plist`

rm $WINDMILL_ROOT/$PROJECT_NAME.mobileprovision.plist

assert_exists "$mobileprovisionUUID" "Could not find an 'iPhone Distribution' provisioning profile that matches the name of the project: "$PROJECT_NAME

(cd $WINDMILL_ROOT/$PROJECT_NAME; $windmill_xcodebuild)

. $SCRIPTS_ROOT/package.sh