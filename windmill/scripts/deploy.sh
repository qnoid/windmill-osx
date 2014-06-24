#!/bin/bash

set -e

echo $IPA

$SCRIPTS_ROOT/s3curl.pl --id=personal --put=$IPA -- https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa

echo "Upload done: https://qnoid.s3-eu-west-1.amazonaws.com/$PROJECT_NAME.ipa"