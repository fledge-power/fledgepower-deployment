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
## Author: Akli Rahmoun
##

VERSION=$1

cd /tmp
wget -O ./fledgepower-filter-tase2topivot.tar.gz https://github.com/fledge-power/fledgepower-filter-tase2topivot/releases/tag/$VERSION.tar.gz
tar -xf fledgepower-filter-tase2topivot.tar.gz
mv fledgepower-filter-tase2topivot-* fledgepower-filter-tase2topivot
cd fledgepower-filter-tase2topivot
chmod +x mkversion

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
make

if [ ! -d "${FLEDGE_ROOT}/plugins/filter/tase2topivot" ] 
then
    sudo mkdir -p ${FLEDGE_ROOT}/plugins/filter/tase2topivot
fi
sudo cp libtase2topivot.so ${FLEDGE_ROOT}/plugins/filter/tase2topivot
