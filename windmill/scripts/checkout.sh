#!/bin/bash

# Requires the following variables to be set
# WINDMILL_ROOT
# SCRIPTS_ROOT
# PROJECT_NAME
# LOCAL_GIT_REPO

. $SCRIPTS_ROOT/common.sh

function git_pull(){
echo "[windmill] [debug] git -C $PROJECT_NAME pull"
(cd $WINDMILL_ROOT; git -C $PROJECT_NAME pull)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone $remote $PROJECT_NAME)
}


assert_exists "$LOCAL_GIT_REPO" "Please drag and drop the project folder that contains the git repo."

echo "[windmill] Project name: '"$PROJECT_NAME"'"
echo "[windmill] Using "$LOCAL_GIT_REPO

set -e

repo_name_at_local_git_repo $LOCAL_GIT_REPO

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone