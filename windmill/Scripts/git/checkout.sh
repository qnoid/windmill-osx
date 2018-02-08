#!/bin/bash

# Requires the following variables to be set
# PROJECT_DIRECTORY
# REPO_NAME
# REMOTE

REPO_NAME=$1
BRANCH=$2
REMOTE=$3

set -e

. $SCRIPTS_ROOT/common.sh


function git_pull(){
(git -C ${REPO_NAME} fetch; git -C ${REPO_NAME} reset --hard origin/master)
}

function git_clone(){
(git clone -b ${BRANCH} ${REMOTE} "${REPO_NAME}")
}

directory_exist_at_path "${REPO_NAME}" git_pull git_clone


# Cases
## 128 fatal: repository [url] does not exist
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 128 fatal: Not a git repository (or any of the parent directories): .git
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 129 fatal: Too many arguments. e.g. when given a directory with white spaces
### Error Domain=io.windmill Code=129 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
