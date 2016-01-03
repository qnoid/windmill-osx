#!/bin/bash

# Requires the following variables to be set
# SCRIPTS_ROOT
# PROJECT_NAME
# LOCAL_GIT_REPO

set -e

. $SCRIPTS_ROOT/common.sh

function git_pull(){
echo "[windmill] [debug] git -C $PROJECT_NAME pull"
(cd $WINDMILL_ROOT; git -C $PROJECT_NAME pull)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone $remote $PROJECT_NAME)
}

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone