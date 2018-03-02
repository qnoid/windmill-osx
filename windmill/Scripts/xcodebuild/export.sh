#!/bin/bash
set -e

XCARCHIVE_FOR_PROJECT=$1
EXPORT_HOME=$2
RESOURCES_ROOT=$3
RESULT_BUNDLE_PATH_FOR_PROJECT=$4

xcodebuild -exportArchive -archivePath "${XCARCHIVE_FOR_PROJECT}" -exportOptionsPlist ${RESOURCES_ROOT}/exportOptions.plist -exportPath "${EXPORT_HOME}" -allowProvisioningUpdates -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}"
## Export 
#
#adHocProvisioningNotFound = 70 //"No matching provisioning profiles found"

