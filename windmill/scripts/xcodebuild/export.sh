#!/bin/bash
set -e

WIDMILL_HOME=$1
PROJECT_NAME=$2
SCHEME=$3
RESOURCES_ROOT=$4

echo "[io.windmill.windmill] [export] [debug] windmill home ${WIDMILL_HOME}"
echo "[io.windmill.windmill] [export] [debug] project name ${PROJECT_NAME}"
echo "[io.windmill.windmill] [export] [debug] scheme ${SCHEME}"

xcodebuild -exportArchive -archivePath ${WIDMILL_HOME}/${PROJECT_NAME}/archive/${SCHEME}.xcarchive -exportOptionsPlist ${RESOURCES_ROOT}/exportOptions.plist -exportPath ${WIDMILL_HOME}/${PROJECT_NAME}/export -allowProvisioningUpdates
## Export
#
#adHocProvisioningNotFound = 70 //"No matching provisioning profiles found"

