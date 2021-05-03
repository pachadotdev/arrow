#!/bin/bash

set -ex

OUTPUT_DIR=$1
QUEUE_REMOTE_URL=$2
TASK_BRANCH=$3
TASK_TAG=$4
UPLOAD_TO_ANACONDA=$5

conda install -y mamba
# $FEEDSTOCK_ROOT/build_steps.sh ${OUTPUT_DIR}

# Upload as Github release
mamba install -y anaconda-client shyaml pygit2 -c conda-forge

pushd $DRONE_WORKSPACE

pip install arrow/dev/archery[crossbow]
which archery
archery crossbow --help
archery crossbow upload-artifacts --help

archery crossbow \
  --queue-path $(pwd) \
  --queue-remote ${QUEUE_REMOTE_URL} \
  upload-artifacts \
  --sha ${TASK_BRANCH} \
  --tag ${TASK_TAG} \
  --pattern "${OUTPUT_DIR}/linux-aarch64/*.tar.bz2"

if [[ "${UPLOAD_TO_ANACONDA}" == "1" ]]; then
  anaconda -t ${CROSSBOW_ANACONDA_TOKEN} upload --force build_artifacts/linux-aarch64/*.tar.bz2
fi

popd
