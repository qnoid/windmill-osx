#!/bin/bash
#$1 the folder with the git repo
PROJECT_LOCAL_FOLDER=$1
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2
RESOURCES_ROOT=$3
USER=$4
WINDMILL_BASE_URL=$5

. $SCRIPTS_ROOT/common.sh

directory_does_not_exist_at_path ~/.windmill mkdir_windmill

function mkdir_windmill() {
mkdir ~/.windmill
}

function git_pull(){
echo "[windmill] git -C $REPO_NAME pull"
(cd $WINDMILL_ROOT; git -C $REPO_NAME pull)
}

function git_clone(){
(cd $WINDMILL_ROOT; git clone $remote $REPO_NAME)
}

PROJECT_NAME=`basename $1`

(
assert_exists "$1" "Please drag and drop the project folder that contains the git repo."

(
echo "[windmill] Using "$1

set -e

remote=`git -C $1 remote -v | grep "fetch" | awk '{print $2}'`

assert_exists "$remote" "Local git repo '"$1"' does not have an origin (fetch) defined"

echo "[windmill] Found remote repo at: "$remote

#local directory to clone to, in the form of foo.git
REPO_NAME=`basename $remote .git`

assert_exists "$REPO_NAME" "Could not parse repo name."

echo "[windmill] Using repo name: "$REPO_NAME

directory_exist_at_path "$WINDMILL_ROOT/$REPO_NAME" git_pull git_clone

. $SCRIPTS_ROOT/build.sh
) 2>&1 | tee $HOME/.windmill/$PROJECT_NAME.log

) 2>&1 | tee $HOME/.windmill/windmill.log