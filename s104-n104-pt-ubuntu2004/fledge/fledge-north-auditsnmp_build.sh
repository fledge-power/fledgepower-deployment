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

git clone https://github.com/fledge-power/fledge-north-auditsnmp
cd fledge-north-auditsnmp/

if [ ! -d "${FLEDGE_ROOT}/python/fledge/plugins/north/auditsnmp" ] 
then
    sudo mkdir -p $FLEDGE_ROOT/python/fledge/plugins/north/auditsnmp
fi
sudo cp -r auditsnmp/ $FLEDGE_ROOT/python/fledge/plugins/north
