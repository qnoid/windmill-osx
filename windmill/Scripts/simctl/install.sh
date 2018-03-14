#!/bin/bash

# Requires the following variables to be set
# DEVICE
# APP_BUNDLE_FOR_PROJECT

DESTINATION_ID=$1
APP_BUNDLE_FOR_PROJECT=$2

xcrun simctl install "${DESTINATION_ID}" "${APP_BUNDLE_FOR_PROJECT}"
