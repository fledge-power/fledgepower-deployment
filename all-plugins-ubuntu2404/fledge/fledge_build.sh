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
## Author: Niels Boussion
##

GITHEAD=$1

# Install SQLite 3 from dianomic sources
cd /tmp
SQLITE_PKG_REPO_NAME="sqlite3-pkg"
git clone https://github.com/dianomic/${SQLITE_PKG_REPO_NAME}.git ${SQLITE_PKG_REPO_NAME}
cd ${SQLITE_PKG_REPO_NAME}/src
./configure --enable-shared=false --enable-static=true --enable-static-shell CFLAGS="-DSQLITE_MAX_COMPOUND_SELECT=900 -DSQLITE_MAX_ATTACHED=62 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_COLUMN_METADATA -fno-common -fPIC"
autoreconf -f -i
make
make install

# Build and install fledge
cd /tmp
wget --no-check-certificate -O ./fledge.tar.gz https://github.com/fledge-iot/fledge/archive/refs/tags/$GITHEAD.tar.gz
tar -xf fledge.tar.gz
cd fledge-*
make
make install

# Install fledge includes
mkdir -p /usr/local/fledge/include/rapidjson/
find C/common/ -name '*.h' -exec cp -prv '{}' '/usr/local/fledge/include' ';'
find C/plugins/ -name '*.h' -exec cp -prv '{}' '/usr/local/fledge/include' ';'
find C/services/ -name '*.h' -exec cp -prv '{}' '/usr/local/fledge/include' ';'
find C/tasks/ -name '*.h' -exec cp -prv '{}' '/usr/local/fledge/include' ';'
find C/thirdparty/Simple-Web-Server/ -name '*.hpp' -exec cp -prv '{}' '/usr/local/fledge/include' ';'
cp -prv C/thirdparty/rapidjson/include/rapidjson/* /usr/local/fledge/include/rapidjson/