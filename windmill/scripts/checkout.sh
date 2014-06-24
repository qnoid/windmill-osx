#!/bin/bash
#$1 the local git repo

(
USES_COCOAPODS=true
WINDMILL_ROOT="$HOME/.windmill"
SCRIPTS_ROOT=$2

. $SCRIPTS_ROOT/common.sh

mkdir ~/.windmill

assert_exists "$1" "Please specify the absolute path to the local git repo"

echo "Using "$1

set -e

remote=`git -C $1 remote -v | grep "fetch" | awk '{print $2}'`

assert_exists "$remote" "Local git repo"$1"does not have an origin (fetch) defined"

echo "Found remote repo at: "$remote

#local directory to clone to, in the form of foo.git
PROJECT_NAME=`basename $remote .git`

assert_exists "$PROJECT_NAME" "Could not parse repo name."

echo "Using repo name: "$PROJECT_NAME

if [ -d "$WINDMILL_ROOT/$PROJECT_NAME" ]; then
    (cd $WINDMILL_ROOT; git -C $PROJECT_NAME pull)
else
	(cd $WINDMILL_ROOT; git clone $remote $PROJECT_NAME)
fi

. $SCRIPTS_ROOT/build.sh
) 2>&1 | tee $HOME/.windmill/windmill.log