#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2021, 2023. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************
set -vex

source open-ce-common-utils.sh

# Build Tensorflow from source
SCRIPT_DIR=$RECIPE_DIR/../buildscripts

# Pick up additional variables defined from the conda build environment
$SCRIPT_DIR/set_python_path_for_bazelrc.sh $SRC_DIR
$SCRIPT_DIR/set_tf_io_bazelrc.sh $SRC_DIR $PY_VER

#sh ${SRC_DIR}/configure.sh
if [[ $build_type == "cuda" ]]
then
  # Pick up the CUDA and CUDNN environment
  $SCRIPT_DIR/set_tf_io_nvidia_bazelrc.sh $SRC_DIR/ $PY_VER
fi

export BAZEL_OPTIMIZATION="--config=optimization"

# install using pip from the whl file
bazel --bazelrc=$SRC_DIR/tf_io.bazelrc build \
      $BAZEL_OPTIMIZATION //tensorflow_io_gcs_filesystem/...

if [ $? -eq 0 ];
then
    echo "bazel build executed successfully"
else
    echo "bazel build terminated unsuccessfully"
    PID=$(bazel info server_pid)
    echo "PID: $PID"
    cleanup_bazel $PID
fi

python setup.py bdist_wheel --data bazel-bin --project tensorflow-io-gcs-filesystem
python -m pip install dist/*.whl

PID=$(bazel info server_pid)
echo "PID: $PID"
cleanup_bazel $PID
