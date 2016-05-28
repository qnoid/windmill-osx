#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME
WINDMILL_ROOT="$HOME/.windmill"

set -e

SCHEME=$1
SIMULATOR_NAME=$2

(
(

xcodebuild test -scheme "$SCHEME" -destination 'platform=iOS Simulator,name=iPhone 4s'

) 2>&1 | tee -a "$WINDMILL_ROOT/$PROJECT_NAME.log"
) 2>&1 | tee -a "$WINDMILL_ROOT/windmill.log"