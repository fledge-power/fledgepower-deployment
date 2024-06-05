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
## Author: Mark Riddoch, Akli Rahmoun, Jeremie Chabod
##


## use a native ubuntu empty docker to test this script:
##    docker run -it --network host --rm -v $(pwd):/workdir -w /workdir ubuntu
##         apt update
##         apt install -y git wget sudo cmake g++ unzip software-properties-common
##         add-apt-repository -y ppa:deadsnakes/ppa
##         apt update
##         apt install -y python3.7 python3-pip 
##         ./fledge-install-include.sh
##         ./fledge-north-opcua_build.sh

VERSION=$1

[ -z "${FLEDGE_N_S2OPCUA_BRANCH}" ] && export FLEDGE_N_S2OPCUA_BRANCH=main
[ -z "${S2OPCUA_BRANCH}" ] && export S2OPCUA_BRANCH=S2OPC_Toolkit_1.3.0

MBEDTLS_REPO_URL="https://github.com/ARMmbed/mbedtls/archive/refs/tags"
MBEDTLS_VERSION="2.28.1"
FLEDGE_REPO_URL="https://github.com/fledge-iot/fledge/archive/refs/tags/v2.0.1.zip" 

# check options
## -f: force a clean
## -d: install depandancies only
## -l: install lib only (do not reinstall depandancies)

BUILD_DEPS=true
BUILD_LIB=true
[ "$1" == "-f" ] && shift && rm -rf ${DEV_ROOT}  2>/dev/null
[ "$1" == "-d" ] && shift && BUILD_LIB=false
[ "$1" == "-l" ] && shift && BUILD_DEPS=false


if ! [ -z "$1" ] ; then
    echo "Build the S2OPC north plugin for fledge. (fledge-north-s2opcua) "
    echo "Usage: $0 [-f] [-n]"
    echo "    -f  : force a full rebuild (clean previous build and rebuild dependancies)"
    echo "    -n  : Do not rebuild dependacies (only rebuild the plugin)"
    echo "Use the 'S2OPCUA_BRANCH' variable to select the S2OPC branch to build (default = S2OPC_Toolkit_1.3.0)"
    echo "Use the 'FLEDGE_N_S2OPCUA_BRANCH' variable to select the fledge-north-s2opcua branch to build (default = main)"
    
    exit 1
fi

echo "Using branch ${FLEDGE_N_S2OPCUA_BRANCH} of fledge-north-s2opcua.git"
echo "Using branch ${S2OPCUA_BRANCH} of S2OPC.git"
export DEV_ROOT=/tmp/dev_n_opc
export DEV_LOG=${DEV_ROOT}/logs
export DEV_PLUGIN=${DEV_ROOT}/fledge-north-s2opcua
export DEV_FLEDGE=${DEV_ROOT}/fledge
export S2OPC_ROOT=${DEV_ROOT}/S2OPC
#export DEV_INST=${DEV_ROOT}/install
# export CMAKE_INSTALL_PREFIX=${DEV_INST}
mkdir -p ${DEV_ROOT} ${DEV_LOG} # ${DEV_INST}


function _fail() {
    echo "Build failed:$1"
    cat ${DEV_LOG}/$1.log
    exit 1
}

function install_libcheck() {
  cd ${DEV_ROOT}
  [ -f check-0.15.2.tar.gz ] || wget https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz
  rm -rf check-0.15.2 2>/dev/null
  tar xf check-0.15.2.tar.gz        || return 1
  cd check-0.15.2                   || return 1
  patch CMakeLists.txt ${DEV_PLUGIN}/patches/check-0.15.2.patch  || return 1
  mkdir -p build && cd build        || return 1
  cmake ..                          || return 1
  make -j4                          || return 1
  sudo make install                 || return 1
}

function install_mbedtls() {
  cd ${DEV_ROOT}
  FILE=v${MBEDTLS_VERSION}.tar.gz
  [ -f ${FILE} ] || wget  ${MBEDTLS_REPO_URL}/${FILE}
  rm -rf mbedtls-${MBEDTLS_VERSION} 2>/dev/null
  tar xf ${FILE}                     || return 1
  cd mbedtls-${MBEDTLS_VERSION}      || return 1
  mkdir build && cd build            || return 1
  cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_TESTS=NO -DBUILD_EXAMPLES=NO -DCMAKE_BUILD_TYPE=Release ..
  make -j8                           || return 1
  sudo make install                 || return 1
}

function install_s2opc() {
  cd ${DEV_ROOT}
  if ! [ -d S2OPC ] ; then
    git clone https://gitlab.com/systerel/S2OPC.git --branch ${S2OPCUA_BRANCH}
  fi
  cd S2OPC 
  git checkout ${S2OPCUA_BRANCH}
  git reset --hard ${S2OPCUA_BRANCH}
  git show --oneline --shortstat 
  git apply ${DEV_PLUGIN}/patches/S2OPC.patch
  export WITH_USER_ASSERT=1
  export S2OPC_CLIENTSERVER_ONLY=1
  export WITH_NANO_EXTENDED=1
  export USE_STATIC_EXT_LIBS=1
  export BUILD_SHARED_LIBS=0 
  export ENABLE_TESTING=0
  export CMAKE_BUILD_TYPE=Release
  ./build.sh
  sudo make  install -C build
}
  
cd ${DEV_ROOT}
[ -d ${DEV_PLUGIN} ] || git clone https://github.com/fledge-power/fledge-north-s2opcua.git  --branch ${FLEDGE_N_S2OPCUA_BRANCH}
cd ${DEV_PLUGIN} || exit 1

if $BUILD_DEPS ; then
    echo "Installing LIBCHECK"
    install_libcheck > ${DEV_LOG}/install_libcheck.log  2>&1  || _fail install_libcheck 
    echo "Installing MBEDTLS"
    install_mbedtls  > ${DEV_LOG}/install_mbedtls.log  2>&1   || _fail install_mbedtls
    echo "Installing S2OPC"
    install_s2opc    > ${DEV_LOG}/install_s2opc.log   2>&1    || _fail install_s2opc
fi

if $BUILD_LIB ;  then

    echo "Building NORTH plugin"
    
    cd ${DEV_PLUGIN}
    chmod +x mkversion
    
    mkdir -p build
    cd build
    cmake -DCMAKE_POLICY_DEFAULT_CMP0074=NEW -DCMAKE_BUILD_TYPE=Release -DFLEDGE_INCLUDE=/usr/local/fledge/include/ -DFLEDGE_LIB=/usr/local/fledge/lib/ ..
    make -j4        ||  exit 1
    if [ ! -d "${FLEDGE_ROOT}/plugins/north/s2opcua" ] 
    then
        sudo mkdir -p $FLEDGE_ROOT/plugins/north/s2opcua
    fi
    sudo cp -a libs2opcua.so* $FLEDGE_ROOT/plugins/north/s2opcua
fi
    
