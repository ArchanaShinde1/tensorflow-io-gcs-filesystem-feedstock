#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
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

#Clean up old bazel cache to avoid problems building TF
bazel clean --expunge
bazel shutdown

# Build Tensorflow from source
SCRIPT_DIR=$RECIPE_DIR/../buildscripts

# Pick up additional variables defined from the conda build environment
$SCRIPT_DIR/set_python_path_for_bazelrc.sh $SRC_DIR
#if [[ $build_type == "cuda" ]]
#then
  # Pick up the CUDA and CUDNN environment
#  $SCRIPT_DIR/set_tensorflow_nvidia_bazelrc.sh $SRC_DIR/tensorflow $PY_VER
#fi

# Build the bazelrc
#$SCRIPT_DIR/set_tensorflow_bazelrc.sh $SRC_DIR/tensorflow

sh ${SRC_DIR}/configure.sh
#BAZEL_OPTIMIZATION="--experimental_repo_remote_exec"

# install using pip from the whl file
#bazel --bazelrc=$SRC_DIR/python_configure.bazelrc build -s \
bazel build -s --verbose_failures $BAZEL_OPTIMIZATION //tensorflow_io_gcs_filesystem/...

python setup.py bdist_wheel --data bazel-bin --project tensorflow-io-gcs-filesystem
python -m pip install dist/*.whl

bazel clean --expunge
bazel shutdown
