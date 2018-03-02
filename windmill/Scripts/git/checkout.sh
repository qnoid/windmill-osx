#!/bin/bash

# Requires the following variables to be set
# PROJECT_DIRECTORY
# REPO_NAME
# REMOTE

REPOSITORY_PATH_FOR_PROJECT=$1
BRANCH=$2
REMOTE=$3
SCRIPTS_ROOT=$4

set -e

. $SCRIPTS_ROOT/common.sh


function git_pull(){
(git -C "${REPOSITORY_PATH_FOR_PROJECT}" fetch --recurse-submodules; git -C "${REPOSITORY_PATH_FOR_PROJECT}" reset --hard origin/"$BRANCH"; git -C "${REPOSITORY_PATH_FOR_PROJECT}" submodule update)
}

function git_clone(){
(git clone --recurse-submodules -b "${BRANCH}" "${REMOTE}" "${REPOSITORY_PATH_FOR_PROJECT}")
}

directory_exist_at_path "${REPOSITORY_PATH_FOR_PROJECT}" git_pull git_clone


# Cases
## 128 fatal: repository [url] does not exist
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 128 fatal: Not a git repository (or any of the parent directories): .git
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 129 fatal: Too many arguments. e.g. when given a directory with white spaces
### Error Domain=io.windmill Code=129 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
