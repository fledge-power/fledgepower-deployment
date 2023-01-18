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

cd /tmp
git clone https://gitlab.com/systerel/S2OPC.git --branch S2OPC_Toolkit_1.2.0
cd S2OPC
./build.sh

wget -O ./fledge-north-s2opcua.tar.gz https://github.com/fledge-power/fledge-north-s2opcua/archive/refs/heads/main.tar.gz
tar -xf fledge-north-s2opcua.tar.gz
mv fledge-north-s2opcua-* fledge-north-s2opcua
cd fledge-north-s2opcua
chmod +x mkversion

mkdir build
cd build
cmake -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
make
if [ ! -d "${FLEDGE_ROOT}/plugins/north/iec104" ] 
then
    sudo mkdir -p $FLEDGE_ROOT/plugins/north/iec104
fi
sudo cp libiec104.so $FLEDGE_ROOT/plugins/north/iec104
