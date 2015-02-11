#!/bin/bash
#$1 the folder with the git repo
PROJECT_LOCAL_FOLDER=$1
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2
RESOURCES_ROOT=$3
USER=$4
WINDMILL_BASE_URL=$5

. $SCRIPTS_ROOT/common.sh

function mkdir_windmill() {
mkdir ~/.windmill
}

function git_pull(){
echo "[windmill] [debug] git -C $REPO_NAME pull"
(cd $WINDMILL_ROOT; git -C $REPO_NAME pull)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone $remote $REPO_NAME)
}

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

LOCAL_GIT_REPO=$1
PROJECT_NAME=`basename "$LOCAL_GIT_REPO"`

(
assert_exists "$LOCAL_GIT_REPO" "Please drag and drop the project folder that contains the git repo."

(
echo "[windmill] Project name: '"$PROJECT_NAME"'"
echo "[windmill] Using "$LOCAL_GIT_REPO

set -e

repo_name_at_local_git_repo $LOCAL_GIT_REPO

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone

. $SCRIPTS_ROOT/build.sh
) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"

) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"