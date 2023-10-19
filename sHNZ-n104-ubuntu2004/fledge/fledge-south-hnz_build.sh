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
## Author: Yannick Marchetaux
##

source /tmp/versions.sh

# Compilation of libHNZ
wget -O ./libhnz.tar.gz https://github.com/fledge-power/libhnz/archive/refs/$VERSION_LIBHNZ.tar.gz
tar -xf libhnz.tar.gz
mv libhnz-* libhnz
cd libhnz
export LIB_HNZ=`pwd`
cd src/hnz
./compilation.sh

# Compilation of fledge-south-hnz
wget -O ./fledge-south-hnz.tar.gz https://github.com/fledge-power/fledge-south-hnz/archive/refs/$VERSION_SOUTH_HNZ.tar.gz
tar -xf fledge-south-hnz.tar.gz
mv fledge-south-hnz-* fledge-south-hnz
cd fledge-south-hnz
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
make
if [ ! -d "${FLEDGE_ROOT}/plugins/south/hnz" ] 
then
    sudo mkdir -p $FLEDGE_ROOT/plugins/south/hnz
fi
sudo cp libhnz.so $FLEDGE_ROOT/plugins/south/hnz
