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

set -ex
BAZEL_RC_DIR=$1

#Determine architecture for specific options
ARCH=`uname -p`

## 
## Use centralized optimization settings
##
NL=$'\n'
BUILD_COPT="build:opt --copt="
BUILD_HOST_COPT="build:opt --host_copt="
if [ -z "${cpu_opt_tune}"]; then
     CPU_ARCH_OPTION='';
     CPU_ARCH_HOST_OPTION='';
else
     if [[ "${ARCH}" == 'x86_64' ]]; then
          CPU_ARCH_FRAG="-march=${cpu_opt_arch}"
     fi
     if [[ "${ARCH}" == 'ppc64le' ]]; then
          CPU_ARCH_FRAG="-mcpu=${cpu_opt_arch}"
     fi

     CPU_ARCH_OPTION=${BUILD_COPT}${CPU_ARCH_FRAG}
     CPU_ARCH_HOST_OPTION=${BUILD_HOST_COPT}${CPU_ARCH_FRAG}
fi

if [ -z "${cpu_opt_tune}"]; then
     CPU_TUNE_OPTION='';
     CPU_TUNE_HOST_OPTION='';
else
     CPU_TUNE_FRAG="-mtune=${cpu_opt_tune}";
     CPU_TUNE_OPTION=${BUILD_COPT}${CPU_TUNE_FRAG}
     CPU_TUNE_HOST_OPTION=${BUILD_HOST_COPT}${CPU_TUNE_FRAG}
fi

if [ -z "${vector_settings}"]; then
     VEC_OPTIONS='';
else
     vecs=$(echo ${vector_settings} | tr "," "\n")
     for setting in $vecs
     do
          VEC_OPTIONS+="build:opt --copt=-m${setting}${NL}"
     done
fi

cat >> $BAZEL_RC_DIR/tensorflow-io.bazelrc << EOF
import %workspace%/python_configure.bazelrc
${CPU_ARCH_OPTION}
${CPU_ARCH_HOST_OPTION}
${CPU_TUNE_OPTION}
${CPU_TUNE_HOST_OPTION}
${VEC_OPTIONS}
build --strip=always
build --color=yes
build --verbose_failures
build --spawn_strategy=standalone
EOF

