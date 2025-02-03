#!/usr/bin/env bash

##--------------------------------------------------------------------
## Copyright (c) 2020 Dianomic Systems
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
## Author: Mark Riddoch, Akli Rahmoun
##

VERSION=$1

wget -O ./libiec61850.tar.gz https://github.com/mz-automation/libiec61850/archive/refs/tags/${VERSION}.tar.gz
tar -xf libiec61850.tar.gz
cd libiec61850*/third_party/mbedtls/
wget https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v2.28.9.tar.gz
tar xf v2.28.9.tar.gz
mv mbedtls-2.28.9/ mbedtls-2.28
cd ../..
mkdir build
cd build
cmake -DBUILD_TESTS=NO -DBUILD_EXAMPLES=NO ..
sed -i "s/CONFIG_MMS_SORT_NAME_LIST 1/CONFIG_MMS_SORT_NAME_LIST 0/" ./config/stack_config.h # disable alphabetic order, for getNameList (server side).
make
sudo make install
