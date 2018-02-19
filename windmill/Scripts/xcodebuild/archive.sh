#!/bin/bash
set -e

SCHEME=$1
CONFIGURATION=$2
DERIVED_DATA_PATH_FOR_PROJECT=$3
ARCHIVE_PATH_FOR_PROJECT=$4

xcodebuild -scheme ${SCHEME} -configuration ${CONFIGURATION} archive -derivedDataPath ${DERIVED_DATA_PATH_FOR_PROJECT} -archivePath ${ARCHIVE_PATH_FOR_PROJECT}

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
