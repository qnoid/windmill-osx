#!/bin/bash

# Requires the following variables to be set

set -eo pipefail

# {URL}/{project name}/build/settings.json
WORKSPACE=$1
SCHEME=$2
BUILD_SETTINGS_FOR_PROJECT=$3
SCRIPTS_ROOT=$4

BUILD_SETTINGS=$(xcodebuild -showBuildSettings -workspace "${WORKSPACE}" -scheme "${SCHEME}" | awk -f "${SCRIPTS_ROOT}/awk/build_settings.awk")

echo ${BUILD_SETTINGS} > "${BUILD_SETTINGS_FOR_PROJECT}"
