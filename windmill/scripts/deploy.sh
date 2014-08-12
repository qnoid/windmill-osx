#!/bin/bash

set -e

echo $IPA
echo $PLIST

curl -v -F "ipa=@$IPA" -F "plist=@$PLIST" http://localhost:8080/windmill/rest/windmill

echo "Upload done: https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa"