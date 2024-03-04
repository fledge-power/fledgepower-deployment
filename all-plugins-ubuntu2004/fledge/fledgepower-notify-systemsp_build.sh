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
## Author: Yannick Marchetaux
##

VERSION=$1

cd /tmp
wget -O ./fledgepower-notify-systemsp.tar.gz https://github.com/fledge-power/fledgepower-notify-systemsp/archive/refs/$VERSION.tar.gz
tar -xf fledgepower-notify-systemsp.tar.gz
mv fledgepower-notify-systemsp-* fledgepower-notify-systemsp
cd fledgepower-notify-systemsp
chmod +x mkversion

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
make

if [ ! -d "${FLEDGE_ROOT}/plugins/notificationDelivery/systemspn" ] 
then
    sudo mkdir -p ${FLEDGE_ROOT}/plugins/notificationDelivery/systemspn
fi
sudo cp libsystemspn.so ${FLEDGE_ROOT}/plugins/notificationDelivery/systemspn