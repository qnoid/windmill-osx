#!/bin/bash
set -eo pipefail

# {URL}/{project name}/configuration.json
WORKSPACE=$1
PROJECT_CONFIGURATION_FOR_PROJECT=$2

PROJECT_CONFIGURATION=$(xcodebuild -list -json -workspace "${WORKSPACE}")

echo ${PROJECT_CONFIGURATION} > "${PROJECT_CONFIGURATION_FOR_PROJECT}"
