#!/bin/bash

# Requires the following variables to be set
# DEVICE
# BUNDLE_IDENTIFIER

DESTINATION_ID=$1
BUNDLE_IDENTIFIER=$2

open "`xcode-select -p`/Applications/Simulator.app"
xcrun simctl boot "${DESTINATION_ID}"
xcrun simctl launch "${DESTINATION_ID}" "${BUNDLE_IDENTIFIER}"
