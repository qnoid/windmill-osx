#!/bin/bash
set -e

XCARCHIVE_FOR_PROJECT=$1
EXPORT_HOME=$2
RESOURCES_ROOT=$3

xcodebuild -exportArchive -archivePath ${XCARCHIVE_FOR_PROJECT} -exportOptionsPlist ${RESOURCES_ROOT}/exportOptions.plist -exportPath ${EXPORT_HOME} -allowProvisioningUpdates
## Export 
#
#adHocProvisioningNotFound = 70 //"No matching provisioning profiles found"

