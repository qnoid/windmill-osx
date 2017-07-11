#!/bin/bash
set -e

IPA=$1
PLIST=$2
ACCOUNT=14810686-4690-4900-ADA5-8B0B7338AA39
WINDMILL_BASE_URL=$3

curl -v -F "ipa=@$1" -F "plist=@$2" $WINDMILL_BASE_URL/account/$ACCOUNT/windmill | grep ^Location | awk '{print $2}'
