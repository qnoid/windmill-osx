#!/bin/bash

#  poll.sh
#  ref: http://stackoverflow.com/questions/7166509/how-to-build-a-git-polling-build-bot

POLL_DIRECTORY=$1
SCRIPTS_ROOT=$2
BRANCH=$3

. $SCRIPTS_ROOT/common.sh

function store_prev_head()
{
echo "[io.windmill.windmill] [poll] [debug] [$FUNCNAME]"
git rev-parse "$BRANCH" > "$POLL_DIRECTORY/prev_head"
}

file_does_not_exist_at_path "$POLL_DIRECTORY/prev_head" store_prev_head

git fetch 2>/dev/null || exit 0
git merge FETCH_HEAD > /dev/null || exit 0
git rev-parse "$BRANCH" > "$POLL_DIRECTORY/latest_head" || exit 0

diff "$POLL_DIRECTORY/latest_head" "$POLL_DIRECTORY/prev_head" > /dev/null
exit_code=$?
if [ $exit_code -eq 1 ]; then
echo "[io.windmill.windmill] [poll] [debug] [Requires update.]"
cat "$POLL_DIRECTORY/latest_head" > "$POLL_DIRECTORY/prev_head"
exit 1
fi
exit $exit_code
## Poll
#
#fatal = 128 //"ambiguous argument 'master': unknown revision or path not in the working tree. Use '--' to separate paths from revisions, like this: 'git <command> [<revision>...] -- [<file>...]"
#branchBehindOrigin = 1
