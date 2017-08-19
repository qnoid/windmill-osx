#!/bin/bash
set -e

SCHEME_NAME=$1
PROJECT_NAME=$2
RESOURCES_ROOT=$3


xcodebuild -scheme $SCHEME_NAME -configuration Release archive -derivedDataPath build -archivePath build/$SCHEME_NAME.xcarchive

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
