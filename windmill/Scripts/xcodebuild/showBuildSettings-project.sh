#!/bin/bash

# Requires the following variables to be set

set -eo pipefail

# {URL}/{project name}/build/settings.json
PROJECT=$1
BUILD_SETTINGS_FOR_PROJECT=$2
SCRIPTS_ROOT=$3

BUILD_SETTINGS=$(xcodebuild -showBuildSettings -project "${PROJECT}" | awk -f "${SCRIPTS_ROOT}/awk/build_settings.awk")

echo ${BUILD_SETTINGS} > "${BUILD_SETTINGS_FOR_PROJECT}"
