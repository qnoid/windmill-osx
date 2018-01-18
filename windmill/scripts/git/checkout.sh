#!/bin/bash

# Requires the following variables to be set
# PROJECT_DIRECTORY
# REPO_NAME
# REMOTE
# SCRIPTS_ROOT

PROJECT_DIRECTORY=$1
SCRIPTS_ROOT=$2
REPO_NAME=$3
BRANCH=$4
REMOTE=$5

set -e

. $SCRIPTS_ROOT/common.sh

echo "[io.windmill.windmill] [checkout] [debug] using directory ${PROJECT_DIRECTORY}"
echo "[io.windmill.windmill] [checkout] [debug] repo name ${REPO_NAME}"
echo "[io.windmill.windmill] [checkout] [debug] branch ${BRANCH}"
echo "[io.windmill.windmill] [checkout] [debug] remote ${REMOTE}"

function git_pull(){
echo "[io.windmill.windmill] [checkout] [debug] git -C ${REPO_NAME} fetch; git -C ${REPO_NAME} reset --hard FETCH_HEAD"
(cd "${PROJECT_DIRECTORY}"; git -C ${REPO_NAME} fetch; git -C ${REPO_NAME} reset --hard FETCH_HEAD)
}

function git_clone(){
echo "[io.windmill.windmill] [checkout] [debug] git clone -b ${BRANCH} ${REMOTE} ${REPO_NAME}"
(cd "${PROJECT_DIRECTORY}"; git clone -b ${BRANCH} ${REMOTE} "${REPO_NAME}")
}

directory_exist_at_path "${PROJECT_DIRECTORY}/${REPO_NAME}" git_pull git_clone


# Cases
## 128 fatal: repository [url] does not exist
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 128 fatal: Not a git repository (or any of the parent directories): .git
### Error Domain=io.windmill Code=128 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
## 129 fatal: Too many arguments. e.g. when given a directory with white spaces
### Error Domain=io.windmill Code=129 "Activity 'checking out' exited with error" UserInfo={type=checkout, NSLocalizedDescription=Activity 'checking out' exited with error}
