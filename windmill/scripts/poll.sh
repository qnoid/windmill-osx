#!/bin/bash

#  poll.sh
#  ref: http://stackoverflow.com/questions/7166509/how-to-build-a-git-polling-build-bot

PROJECT_LOCAL_FOLDER=$1
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2
BRANCH=$3

. $SCRIPTS_ROOT/common.sh

LOCAL_GIT_REPO=$1
PROJECT_NAME=`basename "$LOCAL_GIT_REPO"`
BUILD_DIR="$WINDMILL_ROOT/$PROJECT_NAME/build"

function store_prev_head()
{
echo "[windmill] [debug] [$FUNCNAME]"
git -C "$LOCAL_GIT_REPO" rev-parse "$BRANCH" > "$BUILD_DIR/prev_head"
}

file_does_not_exist_at_path "$BUILD_DIR/prev_head" store_prev_head

(
(
git -C "$LOCAL_GIT_REPO" fetch
if [ $? -eq 0 ]
then
git -C "$LOCAL_GIT_REPO" merge FETCH_HEAD
git -C "$LOCAL_GIT_REPO" rev-parse "$BRANCH" > "$BUILD_DIR/latest_head"
if ! diff "$BUILD_DIR/latest_head" "$BUILD_DIR/prev_head" > /dev/null ;
then
echo "[windmill] [debug] [Requires update.]"
cat "$BUILD_DIR/latest_head" > "$BUILD_DIR/prev_head"
exit 1
fi
fi
) 2>&1 | tee "$WINDMILL_ROOT/$PROJECT_NAME.log"
) 2>&1 | tee "$WINDMILL_ROOT/windmill.log"