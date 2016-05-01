#!/bin/bash

# Requires the following variables to be set
# SCHEME_NAME

set -e

PROJECT_NAME=$1

(
(

xcodebuild -scheme $PROJECT_NAME -configuration Debug clean build -derivedDataPath build

) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"
) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"
