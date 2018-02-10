#!/bin/bash
set -e

PROJECT_NAME=$1
SCHEME=$2
CONFIGURATION=$3
WIDMILL_HOME=$4
BUILD_DIRECTORY_FOR_PROJECT=$5
ARCHIVE_DIRECTORY_FOR_PROJECT=$6

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} archive -derivedDataPath ${BUILD_DIRECTORY_FOR_PROJECT} -archivePath ${ARCHIVE_DIRECTORY_FOR_PROJECT}/${SCHEME}.xcarchive

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
