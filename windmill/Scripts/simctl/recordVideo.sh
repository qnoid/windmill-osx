#!/bin/bash

# Requires the following variables to be set
# DESTINATION_ID
# PATH_FOR_VIDEO_FILE

DESTINATION_ID=$1
PATH_FOR_VIDEO_FILE=$2

xcrun simctl io "${DESTINATION_ID}" recordVideo "${PATH_FOR_VIDEO_FILE}"
