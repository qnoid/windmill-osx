#!/bin/bash

#  poll.sh
#  ref: http://stackoverflow.com/questions/7166509/how-to-build-a-git-polling-build-bot

BRANCH=$1

. $SCRIPTS_ROOT/common.sh

function store_prev_head()
{
git rev-parse "$BRANCH" > "$POLL_DIRECTORY_FOR_PROJECT/prev_head" || exit 0
}

file_does_not_exist_at_path "$POLL_DIRECTORY_FOR_PROJECT/prev_head" store_prev_head

git fetch 2>/dev/null || exit 0
git reset --hard origin/"$BRANCH" > /dev/null || exit 0
git rev-parse "$BRANCH" > "$POLL_DIRECTORY_FOR_PROJECT/latest_head" || exit 0

diff "$POLL_DIRECTORY_FOR_PROJECT/latest_head" "$POLL_DIRECTORY_FOR_PROJECT/prev_head" > /dev/null
exit_code=$?
if [ $exit_code -eq 1 ]; then
cat "$POLL_DIRECTORY_FOR_PROJECT/latest_head" > "$POLL_DIRECTORY_FOR_PROJECT/prev_head"
exit 1
fi
exit $exit_code
## Poll
#
#fatal = 128 //"ambiguous argument 'master': unknown revision or path not in the working tree. Use '--' to separate paths from revisions, like this: 'git <command> [<revision>...] -- [<file>...]"
#branchBehindOrigin = 1
