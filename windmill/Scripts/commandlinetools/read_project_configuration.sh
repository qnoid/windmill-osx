#!/bin/bash
set -e

# {URL}/{project name}/configuration.json
PROJECT_CONFIGURATION_FOR_PROJECT=$1

PROJECT_CONFIGURATION=$(xcodebuild -list -json)

echo ${PROJECT_CONFIGURATION} > "${PROJECT_CONFIGURATION_FOR_PROJECT}"
