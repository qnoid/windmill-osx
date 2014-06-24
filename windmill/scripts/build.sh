#!/bin/bash
#$1 path of clone

. $SCRIPTS_ROOT/common.sh

set -e

if [ $USES_COCOAPODS ]; then
    export LANG=en_US.UTF-8
    (cd $WINDMILL_ROOT/$PROJECT_NAME; /Users/qnoid/.rbenv/shims/pod install)
fi

#set -o pipefail && xcodebuild $1.xcworkspace | xcpretty -c
mobileprovisionUUID=`security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/$PROJECT_NAME.mobileprovision > $HOME/.windmill/$PROJECT_NAME.mobileprovision.plist; /usr/libexec/PlistBuddy -c "Print :UUID" $HOME/.windmill/$PROJECT_NAME.mobileprovision.plist`

assert_exists "$mobileprovisionUUID" "Could not find an 'iPhone Distribution' provisioning profile that matches the name of the project: "$PROJECT_NAME

(cd $WINDMILL_ROOT/$PROJECT_NAME; xcodebuild -workspace $PROJECT_NAME.xcworkspace -scheme $PROJECT_NAME -configuration Release clean build -derivedDataPath build PROVISIONING_PROFILE=$mobileprovisionUUID)

. $SCRIPTS_ROOT/package.sh