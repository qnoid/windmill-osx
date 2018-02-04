#!/bin/bash
set -e

WIDMILL_HOME=$1
PROJECT_NAME=$2
SCHEME=$3
CONFIGURATION=$4

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} archive -derivedDataPath ${WIDMILL_HOME}/${PROJECT_NAME}/build -archivePath ${WIDMILL_HOME}/${PROJECT_NAME}/archive/${SCHEME}.xcarchive

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
