#!/bin/bash

##--------------------------------------------------------------------
## Copyright (c) 2022, RTE (https://www.rte-france.com)
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##--------------------------------------------------------------------

##
## Author: Akli Rahmoun
##

cd /tmp

git clone https://x-token-auth:$TASE2_REPO_ACCESS_TOKEN@bitbucket.org/mzillgith/libtase2-release.git
cd libtase2-release
export LIB_TASE2=$PWD
mkdir build
cd build
cmake -DBUILD_TESTS=NO -DBUILD_EXAMPLES=NO ..
make
sudo make install
sudo ldconfig

apt install --yes libgtest-dev