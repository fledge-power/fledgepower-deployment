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

wget --no-check-certificate  http://archives.fledge-iot.org/2.0.1/bullseye/armv7l/fledge-s2opcua_2.0.1_armv7l.deb
dpkg --unpack ./fledge-s2opcua_2.0.1_armv7l.deb
apt-get install -yf
apt-get clean -y
