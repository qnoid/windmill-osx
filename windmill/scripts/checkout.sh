#!/bin/bash

# Requires the following variables to be set
# WINDMILL_ROOT
# SCRIPTS_ROOT
# PROJECT_NAME
# REPO_NAME
# REMOTE

. $SCRIPTS_ROOT/common.sh

function git_pull(){
echo "[windmill] [debug] git -C $PROJECT_NAME pull"
(cd $WINDMILL_ROOT; git -C $PROJECT_NAME pull)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone $REMOTE $PROJECT_NAME)
}

set -e

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone