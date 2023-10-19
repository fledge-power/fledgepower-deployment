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

git clone https://github.com/fledge-iot/fledge.git
cd fledge
sudo mkdir -p /usr/local/fledge/include/rapidjson/
find C/common/ -name '*.h' -exec sudo cp -prv '{}' '/usr/local/fledge/include' ';'
find C/plugins/ -name '*.h' -exec sudo cp -prv '{}' '/usr/local/fledge/include' ';'
find C/services/ -name '*.h' -exec sudo cp -prv '{}' '/usr/local/fledge/include' ';'
find C/tasks/ -name '*.h' -exec sudo cp -prv '{}' '/usr/local/fledge/include' ';'
find C/thirdparty/Simple-Web-Server/ -name '*.hpp' -exec sudo cp -prv '{}' '/usr/local/fledge/include' ';'
sudo cp -prv C/thirdparty/rapidjson/include/rapidjson/* /usr/local/fledge/include/rapidjson/