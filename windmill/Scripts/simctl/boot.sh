#!/bin/bash

# Requires the following variables to be set
# DESTINATION_ID

DESTINATION_ID=$1

xcrun simctl boot "${DESTINATION_ID}"
