#!/bin/bash
PROJECT=$1
SCHEME=$2
CONFIGURATION=$3
DERIVED_DATA_PATH_FOR_PROJECT=$4
ARCHIVE_PATH_FOR_PROJECT=$5
RESULT_BUNDLE_PATH_FOR_PROJECT=$6
LOG_FOR_PROJECT=$7

set -eo pipefail

xcodebuild -project "${PROJECT}".xcodeproj -scheme "${SCHEME}" -configuration "${CONFIGURATION}" archive -derivedDataPath "${DERIVED_DATA_PATH_FOR_PROJECT}" -archivePath "${ARCHIVE_PATH_FOR_PROJECT}" -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}" 2>&1 | tee -a "${LOG_FOR_PROJECT}"

## Archive
#
#    /**
#     Cases
#
#     * "Code Sign error: No code signing identities found: No valid signing identities (i.e. certificate and private key pair) were found."
#     * "Code Sign error: No matching provisioning profiles found: No provisioning profiles matching an applicable signing identity were found."
#
#     */
#codeSignError = 65
