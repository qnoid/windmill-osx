#!/bin/bash

# Requires the following variables to be set

set -e

# {URL}/{project name}/build/settings.json
BUILD_SETTINGS_FOR_PROJECT=$1
SCHEME=$2

DEPLOYMENT_TARGET=$(xcodebuild -showBuildSettings -scheme ${SCHEME} | awk '$1 == "IPHONEOS_DEPLOYMENT_TARGET" { print $3 }')

echo '{"deployment":{"target":"'${DEPLOYMENT_TARGET}'"}}' > "${BUILD_SETTINGS_FOR_PROJECT}"
