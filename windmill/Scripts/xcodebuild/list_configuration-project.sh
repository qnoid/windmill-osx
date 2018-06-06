#!/bin/bash
set -eo pipefail

# {URL}/{project name}/configuration.json
PROJECT=$1
PROJECT_CONFIGURATION_FOR_PROJECT=$2

PROJECT_CONFIGURATION=$(xcodebuild -list -json -project "${PROJECT}")

echo ${PROJECT_CONFIGURATION} > "${PROJECT_CONFIGURATION_FOR_PROJECT}"
