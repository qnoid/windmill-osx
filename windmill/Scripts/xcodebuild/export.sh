#!/bin/bash
XCARCHIVE_FOR_PROJECT=$1
EXPORT_HOME=$2
RESOURCES_ROOT=$3
RESULT_BUNDLE_PATH_FOR_PROJECT=$4
LOG_FOR_PROJECT=$5

set -eo pipefail

xcodebuild -exportArchive -archivePath "${XCARCHIVE_FOR_PROJECT}" -exportOptionsPlist ${RESOURCES_ROOT}/exportOptions.plist -exportPath "${EXPORT_HOME}" -allowProvisioningUpdates -resultBundlePath "${RESULT_BUNDLE_PATH_FOR_PROJECT}" 2>&1 | tee -a "${LOG_FOR_PROJECT}"
## Export 
#
#adHocProvisioningNotFound = 70 //"No matching provisioning profiles found"

