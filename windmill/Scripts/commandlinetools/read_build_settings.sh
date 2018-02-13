#!/bin/bash

# Requires the following variables to be set

set -e
set -o pipefail

# {URL}/{project name}/build/settings.json
BUILD_SETTINGS_FOR_PROJECT=$1
SCHEME=$2

BUILD_SETTINGS=$(xcodebuild -showBuildSettings -scheme $SCHEME | awk 'BEGIN { ORS=" " }; $1 =="PRODUCT_NAME" { print "\"product\":{\"name\":\""$3"\"}}" }; $1 == "IPHONEOS_DEPLOYMENT_TARGET" { print "{\"deployment\":{\"target\":"$3"}," }')

echo ${BUILD_SETTINGS} > "${BUILD_SETTINGS_FOR_PROJECT}"
