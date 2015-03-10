#!/bin/bash
PROJECT_LOCAL_FOLDER=$1
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2

set -e

. $SCRIPTS_ROOT/common.sh

function mkdir_windmill() {
mkdir ~/.windmill
}

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

LOCAL_GIT_REPO=$1
PROJECT_NAME=`basename "$LOCAL_GIT_REPO"`

(
(
. $SCRIPTS_ROOT/checkout.sh

. $SCRIPTS_ROOT/build.sh

) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"

) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"
