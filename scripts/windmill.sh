#!/bin/bash
set -e

IPA=$1
PLIST=$2
ACCOUNT=$4
WINDMILL_BASE_URL=$3

curl -v -F "ipa=@$1" -F "plist=@$2" $WINDMILL_BASE_URL/account/$ACCOUNT/export | grep ^Location | awk '{print $2}'
