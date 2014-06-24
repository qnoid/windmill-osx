#!/bin/bash

set -e

echo $IPA

$APP_ROOT/scripts/s3curl.pl --id=personal --put=$IPA -- https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa

echo "Upload done: https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa"