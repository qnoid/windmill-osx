#!/bin/bash

#  poll.sh
#  ref: http://stackoverflow.com/questions/7166509/how-to-build-a-git-polling-build-bot

REPO_NAME=$1
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2
BRANCH=$3

. $SCRIPTS_ROOT/common.sh

PROJECT_NAME=$REPO_NAME
BUILD_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build"

function store_prev_head()
{
echo "[windmill] [debug] [$FUNCNAME]"
git -C "$WINDMILL_ROOT/$REPO_NAME" rev-parse "$BRANCH" > "$BUILD_DIR/prev_head"
}

set -e

file_does_not_exist_at_path "$BUILD_DIR/prev_head" store_prev_head

git -C "$WINDMILL_ROOT/$REPO_NAME" fetch
if [ $? -eq 0 ]
then
git -C "$WINDMILL_ROOT/$REPO_NAME" merge FETCH_HEAD
git -C "$WINDMILL_ROOT/$REPO_NAME" rev-parse "$BRANCH" > "$BUILD_DIR/latest_head"
if ! diff "$BUILD_DIR/latest_head" "$BUILD_DIR/prev_head" > /dev/null ;
then
echo "[windmill] [debug] [Requires update.]"
cat "$BUILD_DIR/latest_head" > "$BUILD_DIR/prev_head"
exit 255
fi
fi