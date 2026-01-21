#!/bin/bash
# Script to prepare the build environment for mmdetection.
#
# Example usage:
#   ./prepare_for_build.sh v3.3.0

set -euxo pipefail

# When run from CI, this script is in build_scripts/prepare_for_build.sh
# and needs to reference patches from that directory
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT=`pwd`

if [ $# -ne 1 ]; then
    echo "Usage: $0 <mmdetection-version>"
    echo "Example: $0 v3.3.0"
    exit 1
fi

MMDETECTION_VERSION=$1

# Ensure that the mmdetection version is supported.
if [ ! -d "${SCRIPT_DIR}/patches/${MMDETECTION_VERSION}" ]; then
    echo "Error: patches/${MMDETECTION_VERSION} directory does not exist"
    exit 1
fi

# Apply patches.
for patch in "${SCRIPT_DIR}/patches/${MMDETECTION_VERSION}"/*.patch; do
    patch -p1 -d ${ROOT} -i ${patch}
done
