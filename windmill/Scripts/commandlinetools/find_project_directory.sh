#!/bin/bash

SOURCES_DIRECTORY_FOR_PROJECT=$1
FILENAME=$2

set -o pipefail

find "${SOURCES_DIRECTORY_FOR_PROJECT}" -name "${FILENAME}" -type d -print0 | xargs -0 -n1 dirname
