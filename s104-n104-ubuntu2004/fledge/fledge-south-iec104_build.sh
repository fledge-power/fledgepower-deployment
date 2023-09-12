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

git clone https://github.com/mz-automation/lib60870.git
cd lib60870/lib60870-C
cd dependencies
wget https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v2.28.2.tar.gz
tar xf v2.28.2.tar.gz
mv mbedtls-2.28.2/ mbedtls-2.28
cd ..
mkdir build
cd build
cmake -DBUILD_TESTS=NO -DBUILD_EXAMPLES=NO ..
make
sudo make install
cd ../../..
wget -O ./fledge-south-iec104.tar.gz https://github.com/fledge-power/fledge-south-iec104/archive/refs/tags/v1.1.0.tar.gz
tar -xf fledge-south-iec104.tar.gz
mv fledge-south-iec104-* fledge-south-iec104
cd fledge-south-iec104
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
make
if [ ! -d "${FLEDGE_ROOT}/plugins/south/iec104" ] 
then
    sudo mkdir -p $FLEDGE_ROOT/plugins/south/iec104
fi
sudo cp libiec104.so $FLEDGE_ROOT/plugins/south/iec104
