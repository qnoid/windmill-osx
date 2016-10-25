#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME

set -e

SCHEME=$1
SIMULATOR_NAME=$2

SIMULATOR_NAME=`instruments -s devices | grep -o '^iPhone [a-zA-Z0-9 ]*' | uniq | sed 's/ $//g' | tail -n 1`
xcodebuild test -scheme "$SCHEME" -destination "platform=iOS Simulator,name=$SIMULATOR_NAME"
