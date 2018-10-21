#!/usr/bin/env bash

#  sdk.sh
#  VidCoin
#
#  Created by Mohamed Taieb on 13/08/2018.
#  Copyright © 2018 Voodoo. All rights reserved.

source config.sh

log "~ Starting : ${FORMAT_BOLD} Build MoPub iOs Sdk ${FORMAT_NORMAL}"

# Default
CONFIGURATION="Debug"
OTHER_CFLAGS="-fembed-bitcode"
BITCODE_GENERATION_MODE="bitcode"

if [[ $1 = "Release" ]]; then
    CONFIGURATION="Release"
fi

COMMAND="clean build"
SCHEME="MoPubSDKFramework"
FRAMEWORK_NAME="MoPubSDKFramework"
XCODEPROJ="MoPubSDK.xcodeproj"
OUTPUT_DIR="build"

# Clean previous build
if [ -d "${OUTPUT_DIR}" ]; then
    rm -rf "${OUTPUT_DIR}"
fi

echo "--> Building ${FORMAT_BOLD}MoPubSDK${FORMAT_NORMAL} SDK with : XCODEPROJ<${XCODEPROJ}> SCHEME<${SCHEME}> COMMAND<${COMMAND}> CONFIGURATION<${CONFIGURATION}> OUTPUT_DIR<${OUTPUT_DIR}>"

# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild ${COMMAND} \
BITCODE_GENERATION_MODE=${BITCODE_GENERATION_MODE} OTHER_CFLAGS="$OTHER_CFLAGS" \
-project ${XCODEPROJ} \
-scheme ${SCHEME} \
-configuration ${CONFIGURATION} \
-arch arm64 \
-arch armv7 \
-arch armv7s \
-sdk "iphoneos" \
-derivedDataPath ${OUTPUT_DIR} | xcpretty

# Copy the device version of framework.

cp -r "${OUTPUT_DIR}/Build/Products/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework" "${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework" \

log "~ Done : ${FORMAT_BOLD}¯\_(ツ)_/¯${FORMAT_NORMAL}"

exit 0
