#!/bin/bash

assert_exists ()
{
if [ -z "$1" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

if_string_is_empty ()
{
echo "[windmill] [debug] [$FUNCNAME] '$1'"
if [ -z "$1" ]; then
$2
fi
}

assert_file_exists_at_path ()
{
if [ ! -f "${1}" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

assert_directory_exists_at_path ()
{
if [ ! -d "${1}" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

file_does_not_exist_at_path ()
{
if [ ! -f "$1" ]; then
$2
fi
}

directory_does_not_exist_at_path ()
{
echo "[windmill] [debug] [$FUNCNAME] $1"
if [ ! -d "$1" ]; then
$2
fi
}

file_exist_at_path ()
{
if [ -f "$1" ]; then
$2
fi
}

function directory_exist_at_path ()
{
echo "[windmill] [debug] [$FUNCNAME] $1"
if [ -d "$1" ]; then
$2
else
$3
fi
}

# Extracts the remote repo
#
# git remote -v
# origin	git@bitbucket.org:qnoid/balance.git (fetch)
# origin	git@bitbucket.org:qnoid/balance.git (push)
#
# @sets $remote  the origin of the git repo as returned by 'git remote -v', i.e. git@bitbucket.org:qnoid/balance.git
# @sets $REPO_NAME
function repo_name_at_local_git_repo ()
{
remote=$(git -C "$1" remote -v | grep "fetch" | awk '{print $2}')

assert_exists "$remote" "Local git repo '$1' does not have an origin (fetch) defined"

echo "[windmill] Found remote repo at: '""$remote""'"

#local directory to clone to, in the form of foo.git
REPO_NAME=$(basename "$remote" .git)

assert_exists "$REPO_NAME" "Could not parse repo name."

echo "[windmill] Using repo name: ""$REPO_NAME"
}
