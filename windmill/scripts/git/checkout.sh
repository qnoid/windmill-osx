#!/bin/bash

# Requires the following variables to be set
# WINDMILL_ROOT
# REPO_NAME
# REMOTE
# SCRIPTS_ROOT
# PROJECT_NAME

WINDMILL_ROOT=$1
REPO_NAME=$2
REMOTE=$3
SCRIPTS_ROOT=$4

PROJECT_NAME=$REPO_NAME

set -e

. $SCRIPTS_ROOT/common.sh

function mkdir_windmill() {
mkdir ~/.windmill
}

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

function git_pull(){
echo "[windmill] [debug] git -C $PROJECT_NAME pull"
(cd "$WINDMILL_ROOT"; git -C "$PROJECT_NAME" fetch; git -C "$PROJECT_NAME" reset --hard FETCH_HEAD)
}

function git_clone(){
(cd "$WINDMILL_ROOT"; git clone -b master $REMOTE "$PROJECT_NAME")
}

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone


# Cases
## 128 fatal: repository [url] does not exist
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 128 fatal: Not a git repository (or any of the parent directories): .git
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 129 fatal: Too many arguments. e.g. when given a directory with white spaces
### Error Domain=io.windmill Code=129 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
