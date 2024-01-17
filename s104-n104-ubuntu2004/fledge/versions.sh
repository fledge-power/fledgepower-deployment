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
## Author: Yannick Marchetaux
##

## fledge-north-iec104_build.sh
VERSION_NORTH_IEC104=tags/v1.2.1
VERSION_MBEDTLS=tags/v2.28.2

## fledge-south-iec104_build.sh
VERSION_SOUTH_IEC104=tags/v1.2.0

## fledge-south-hnz_build.sh
VERSION_LIBHNZ=heads/develop
VERSION_SOUTH_HNZ=heads/develop

## fledgepower-filter-iec104topivot_build.sh
VERSION_IEC104_TO_PIVOT=tags/v1.2.0

## fledgepower-filter-hnztopivot_build.sh
VERSION_HNZ_TO_PIVOT=heads/develop

## fledgepower-filter-mvscale_build.sh
VERISON_MVSCALE=tags/1.0.0

## fledgepower-filter-transientsp_build.sh
VERISON_TRANSIENT=tags/v1.0.0

## fledgepower-notify-systemsp_build.sh
VERISON_SYSTEMSP_NOTIFY=heads/develop

## fledgepower-rule-systemsp_build.sh
VERISON_SYSTEMSP_RULE=heads/develop