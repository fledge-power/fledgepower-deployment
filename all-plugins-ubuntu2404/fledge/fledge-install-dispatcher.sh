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
## Author: Mark Riddoch, Akli Rahmoun
##
FLEDGEDISPATCHVERSION=$1
RELEASE=$2
OPERATINGSYSTEM=$3
ARCHITECTURE=$4
FLEDGELINK="http://archives.fledge-iot.org/$RELEASE/$OPERATINGSYSTEM/$ARCHITECTURE"

wget --no-check-certificate ${FLEDGELINK}/fledge-service-dispatcher_${FLEDGEDISPATCHVERSION}_${ARCHITECTURE}.deb
dpkg --unpack ./fledge-service-dispatcher_${FLEDGEDISPATCHVERSION}_${ARCHITECTURE}.deb
apt-get install -yf
apt-get clean -y
