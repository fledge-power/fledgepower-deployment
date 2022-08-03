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

git clone https://github.com/aklira/fledgepower-filter-104todp.git
cd fledgepower-filter-104todp/python/fledge/plugins/filter/


if [ ! -d "${FLEDGE_ROOT}/python/fledge/plugins/filter/104todp" ] 
then
    sudo mkdir -p $FLEDGE_ROOT/python/fledge/plugins/filter/104todp
fi
sudo cp -r 104todp/ $FLEDGE_ROOT/python/fledge/plugins/filter
