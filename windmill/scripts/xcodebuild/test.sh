#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME


set -e

SCHEME=$1
SIMULATOR_NAME=$2

(
(

xcodebuild test -scheme "$SCHEME" -destination 'platform=iOS Simulator,name=iPhone 4s'

) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"
) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"