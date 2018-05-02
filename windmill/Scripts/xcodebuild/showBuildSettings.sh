#!/bin/bash

# Requires the following variables to be set

set -eo pipefail

# {URL}/{project name}/build/settings.json
BUILD_SETTINGS_FOR_PROJECT=$1
SCRIPTS_ROOT=$2

BUILD_SETTINGS=$(xcodebuild -showBuildSettings | awk -f "${SCRIPTS_ROOT}/awk/build_settings.awk")

echo ${BUILD_SETTINGS} > "${BUILD_SETTINGS_FOR_PROJECT}"
