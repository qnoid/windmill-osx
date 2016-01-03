#!/bin/bash
WINDMILL_ROOT="$HOME/.windmill"
REPO_NAME=$1
REMOTE=$2
SCRIPTS_ROOT=$3
RESOURCES_ROOT=$4
USER=$5
WINDMILL_BASE_URL=$6

set -e

. $SCRIPTS_ROOT/common.sh

function mkdir_windmill() {
mkdir ~/.windmill
}

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

PROJECT_NAME=$REPO_NAME

((
. $SCRIPTS_ROOT/checkout.sh

. $SCRIPTS_ROOT/build.sh

. $SCRIPTS_ROOT/package.sh

. $SCRIPTS_ROOT/deploy.sh

) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"

) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"

