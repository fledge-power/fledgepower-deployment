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

curl -sSLo fledge-pkg.zip https://github.com/fledge-iot/fledge/archive/refs/heads/develop.zip
unzip -o fledge-pkg.zip -d $HOME
mv $HOME/fledge-develop $HOME/fledge
cd $HOME/fledge
sudo apt-get update
sudo apt-get install libcurl4-openssl-dev
sudo $HOME/fledge/requirements.sh
sudo make install
sudo mkdir -p /usr/lib/fledge/
sudo cp -prv /usr/local/fledge/lib/* /usr/lib/fledge/
