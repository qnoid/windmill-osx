#!/bin/bash
#$1 the local git repo
(
USES_COCOAPODS=true
WINDMILL_ROOT="$HOME/.windmill"

assert_exists ()
{
if [ -z "$1" ]; then
echo $2
exit 1
fi
}

echo "PWD '"`pwd`"'"
echo "whoami '"`whoami`"'"

. $APP_ROOT/scripts/common.sh

mkdir ~/.windmill

assert_exists "$1" "Please specify the absolute path to the local git repo"

echo "Using "$1

set -e

remote=`git -C $1 remote -v | grep "fetch" | awk '{print $2}'`

assert_exists "$remote" "Local git repo"$1"does not have an origin (fetch) defined"

echo "Found remote repo at: "$remote

#local directory to clone to, in the form of foo.git
PROJECT_NAME=`basename $remote .git`

assert_exists "$PROJECT_NAME" "Could not parse repo name."

echo "Using repo name: "$PROJECT_NAME

if [ -d "$WINDMILL_ROOT/$PROJECT_NAME" ]; then
    (cd $WINDMILL_ROOT; git -C $PROJECT_NAME pull)
else
	(cd $WINDMILL_ROOT; git clone $remote $PROJECT_NAME)
fi

#build.sh
if [ $USES_COCOAPODS ]; then
export LANG=en_US.UTF-8
(cd $WINDMILL_ROOT/$PROJECT_NAME; /Users/qnoid/.rbenv/shims/pod install)
fi

#set -o pipefail && xcodebuild $1.xcworkspace | xcpretty -c
mobileprovisionUUID=`security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/$PROJECT_NAME.mobileprovision > $HOME/.windmill/$PROJECT_NAME.mobileprovision.plist; /usr/libexec/PlistBuddy -c "Print :UUID" $HOME/.windmill/$PROJECT_NAME.mobileprovision.plist`

assert_exists "$mobileprovisionUUID" "Could not find an 'iPhone Distribution' provisioning profile that matches the name of the project: "$PROJECT_NAME

(cd $WINDMILL_ROOT/$PROJECT_NAME; xcodebuild -workspace $PROJECT_NAME.xcworkspace -scheme $PROJECT_NAME -configuration Release clean build -derivedDataPath build PROVISIONING_PROFILE=$mobileprovisionUUID)

#package.sh
echo $PROJECT_NAME

DERIVED_DATA_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build/Build/Products/Release-iphoneos"

xcrun -sdk iphoneos PackageApplication -v $DERIVED_DATA_DIR/$PROJECT_NAME.app

IPA=$DERIVED_DATA_DIR/$PROJECT_NAME.ipa
PLIST=$WINDMILL_ROOT/$PROJECT_NAME.plist

#deploy.sh
echo $IPA

/Users/qnoid/Developer/workspace/swift/windmill/windmill/scripts/s3curl.pl --id=personal --put=$IPA -- https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa

echo "Upload done: https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa"

) 2>&1 | tee $HOME/.windmill/windmill.log