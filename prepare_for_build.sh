#!/bin/bash
# Script to prepare the build environment for mmcv.
#
# Example usage:
#   ./prepare_for_build.sh v2.2.0

set -euxo pipefail

export ROOT=`pwd`

if [ $# -ne 1 ]; then
    echo "Usage: $0 <mmcv-version>"
    echo "Example: $0 v2.2.0"
    exit 1
fi

MMCV_VERSION=$1

# Ensure that the mmcv version is supported.
if [ ! -d "${ROOT}/build_scripts/patches/${MMCV_VERSION}" ]; then
    echo "Error: patches/${MMCV_VERSION} directory does not exist"
    exit 1
fi

# Apply patches.
for patch in "${ROOT}/build_scripts/patches/${MMCV_VERSION}"/*.patch; do
    patch -p1 -d ${ROOT} -i ${patch}
done
