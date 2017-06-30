#!/bin/bash

# Requires the following variables to be set
# WINDMILL_ROOT
# REPO_NAME
# REMOTE
# SCRIPTS_ROOT
# PROJECT_NAME

WINDMILL_ROOT="$HOME/.windmill"
REPO_NAME=$1
REMOTE=$2
SCRIPTS_ROOT=$3

PROJECT_NAME=$REPO_NAME

set -e

. $SCRIPTS_ROOT/common.sh

function mkdir_windmill() {
mkdir ~/.windmill
}

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

function git_pull(){
echo "[windmill] [debug] git -C $PROJECT_NAME pull"
(cd $WINDMILL_ROOT; git -C $PROJECT_NAME fetch; git -C $PROJECT_NAME reset --hard FETCH_HEAD)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone -b master $REMOTE $PROJECT_NAME)
}

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone
