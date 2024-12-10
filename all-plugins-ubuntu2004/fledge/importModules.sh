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

# Possible connections between north and south services:
# NB: groups 1.1 and 1.2 are mutually exclusive, groups 2.1 and 2.2 are mutually exclusive
# Group     |     1.1     |     1.2     ||    2.1      |     2.2     |
# Center    | c1 c2 c3 c4 | c1 c2 c3 c4 || c5 c6 c7 c8 | c5 c6 c7 c8 |
# PMP north | n1 n2 n3 n4 | n1 n2 n3 n4 || n5 n6 n7 n8 | n5 n6 n7 n8 |
#           | \  \  /  /  | \  \  /  /  || \  \  /  /  | \  \  /  /  |
#           |   \ \/ /    |   \ \/ /    ||   \ \/ /    |   \ \/ /    |
# PMP south |     s1      |     s3      ||     s2      |     s4      |
# PA        |   p1 (HNZ)  |   p1 (104)  ||   p2 (HNZ)  |   p2 (104)  |

# Constants
s1_south_service_name="hnzsouth_s1"
s2_south_service_name="hnzsouth_s2"
s3_south_service_name="iec104south_s1"
s4_south_service_name="iec104south_s2"
s1_south_service_name_advanced="${s1_south_service_name}Advanced"
s2_south_service_name_advanced="${s2_south_service_name}Advanced"
s3_south_service_name_advanced="${s3_south_service_name}Advanced"
s4_south_service_name_advanced="${s4_south_service_name}Advanced"

n1_north_service_name="iec104north_c1"
n2_north_service_name="iec104north_c2"
n3_north_service_name="iec104north_c3"
n4_north_service_name="iec104north_c4"
n5_north_service_name="iec104north_c5"
n6_north_service_name="iec104north_c6"
n7_north_service_name="iec104north_c7"
n8_north_service_name="iec104north_c8"
n1_north_service_name_advanced="${n1_north_service_name}Advanced"
n2_north_service_name_advanced="${n2_north_service_name}Advanced"
n3_north_service_name_advanced="${n3_north_service_name}Advanced"
n4_north_service_name_advanced="${n4_north_service_name}Advanced"
n5_north_service_name_advanced="${n5_north_service_name}Advanced"
n6_north_service_name_advanced="${n6_north_service_name}Advanced"
n7_north_service_name_advanced="${n7_north_service_name}Advanced"
n8_north_service_name_advanced="${n8_north_service_name}Advanced"

snmp_north_service_name="auditsnmpnorth"

plugin_1="iec104_pivot_filter"
plugin_2="transientsp"
plugin_3="hnz_pivot_filter"
plugin_4="mvscale"
plugin_5="spoperators"

name_service_notif="notif"
notif_plugin_1="systemspr"
notif_plugin_2="systemspn"
notif_name_1="notif_systemsp_${s1_south_service_name}"
notif_name_2="notif_systemsp_${s2_south_service_name}"
notif_name_3="notif_systemsp_${s3_south_service_name}"
notif_name_4="notif_systemsp_${s4_south_service_name}"

# Group 1.1
ctrl_pipeline_1="${n1_north_service_name}_to_${s1_south_service_name}"
ctrl_pipeline_2="${n2_north_service_name}_to_${s1_south_service_name}"
ctrl_pipeline_3="${n3_north_service_name}_to_${s1_south_service_name}"
ctrl_pipeline_4="${n4_north_service_name}_to_${s1_south_service_name}"
# Group 1.2
ctrl_pipeline_5="${n1_north_service_name}_to_${s3_south_service_name}"
ctrl_pipeline_6="${n2_north_service_name}_to_${s3_south_service_name}"
ctrl_pipeline_7="${n3_north_service_name}_to_${s3_south_service_name}"
ctrl_pipeline_8="${n4_north_service_name}_to_${s3_south_service_name}"
# Group 2.1
ctrl_pipeline_9="${n5_north_service_name}_to_${s2_south_service_name}"
ctrl_pipeline_10="${n6_north_service_name}_to_${s2_south_service_name}"
ctrl_pipeline_11="${n7_north_service_name}_to_${s2_south_service_name}"
ctrl_pipeline_12="${n8_north_service_name}_to_${s2_south_service_name}"
# Group 2.2
ctrl_pipeline_9="${n5_north_service_name}_to_${s4_south_service_name}"
ctrl_pipeline_10="${n6_north_service_name}_to_${s4_south_service_name}"
ctrl_pipeline_11="${n7_north_service_name}_to_${s4_south_service_name}"
ctrl_pipeline_12="${n8_north_service_name}_to_${s4_south_service_name}"

# Group 1.1
ctrl_filter_1_sp="${ctrl_pipeline_1}_source_to_pivot_filter"
ctrl_filter_1_pd="${ctrl_pipeline_1}_pivot_to_destination_filter"
ctrl_filter_2_sp="${ctrl_pipeline_2}_source_to_pivot_filter"
ctrl_filter_2_pd="${ctrl_pipeline_2}_pivot_to_destination_filter"
ctrl_filter_3_sp="${ctrl_pipeline_3}_source_to_pivot_filter"
ctrl_filter_3_pd="${ctrl_pipeline_3}_pivot_to_destination_filter"
ctrl_filter_4_sp="${ctrl_pipeline_4}_source_to_pivot_filter"
ctrl_filter_4_pd="${ctrl_pipeline_4}_pivot_to_destination_filter"
# Group 1.2
ctrl_filter_5_sp="${ctrl_pipeline_5}_source_to_pivot_filter"
ctrl_filter_5_pd="${ctrl_pipeline_5}_pivot_to_destination_filter"
ctrl_filter_6_sp="${ctrl_pipeline_6}_source_to_pivot_filter"
ctrl_filter_6_pd="${ctrl_pipeline_6}_pivot_to_destination_filter"
ctrl_filter_7_sp="${ctrl_pipeline_7}_source_to_pivot_filter"
ctrl_filter_7_pd="${ctrl_pipeline_7}_pivot_to_destination_filter"
ctrl_filter_8_sp="${ctrl_pipeline_8}_source_to_pivot_filter"
ctrl_filter_8_pd="${ctrl_pipeline_8}_pivot_to_destination_filter"
# Group 2.1
ctrl_filter_9_sp="${ctrl_pipeline_9}_source_to_pivot_filter"
ctrl_filter_9_pd="${ctrl_pipeline_9}_pivot_to_destination_filter"
ctrl_filter_10_sp="${ctrl_pipeline_10}_source_to_pivot_filter"
ctrl_filter_10_pd="${ctrl_pipeline_10}_pivot_to_destination_filter"
ctrl_filter_11_sp="${ctrl_pipeline_11}_source_to_pivot_filter"
ctrl_filter_11_pd="${ctrl_pipeline_11}_pivot_to_destination_filter"
ctrl_filter_12_sp="${ctrl_pipeline_12}_source_to_pivot_filter"
ctrl_filter_12_pd="${ctrl_pipeline_12}_pivot_to_destination_filter"
# Group 2.2
ctrl_filter_13_sp="${ctrl_pipeline_13}_source_to_pivot_filter"
ctrl_filter_13_pd="${ctrl_pipeline_13}_pivot_to_destination_filter"
ctrl_filter_14_sp="${ctrl_pipeline_14}_source_to_pivot_filter"
ctrl_filter_14_pd="${ctrl_pipeline_14}_pivot_to_destination_filter"
ctrl_filter_15_sp="${ctrl_pipeline_15}_source_to_pivot_filter"
ctrl_filter_15_pd="${ctrl_pipeline_15}_pivot_to_destination_filter"
ctrl_filter_16_sp="${ctrl_pipeline_16}_source_to_pivot_filter"
ctrl_filter_16_pd="${ctrl_pipeline_16}_pivot_to_destination_filter"

# Create service south
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s1_south_service_name'","type":"south","plugin":"hnz","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s2_south_service_name'","type":"south","plugin":"hnz","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s3_south_service_name'","type":"south","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s4_south_service_name'","type":"south","plugin":"iec104","enabled":false}'

# Create service north
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n1_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n2_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n3_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n4_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n5_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n6_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n7_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n8_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$snmp_north_service_name'","type":"north","plugin":"auditsnmp","enabled":false}'

# Create service notification
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$name_service_notif'","type":"notification","enabled":true}'

# Create plugins
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_4'", "plugin": "'$plugin_4'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_5'", "plugin": "'$plugin_5'"}'
# Group 1.1
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_1_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_1_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_2_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_2_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_3_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_3_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_4_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_4_pd'", "plugin": "'$plugin_3'"}'
# Group 1.2
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_5_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_5_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_6_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_6_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_7_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_7_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_8_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_8_pd'", "plugin": "'$plugin_1'"}'
# Group 2.1
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_9_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_9_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_10_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_10_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_11_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_11_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_12_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_12_pd'", "plugin": "'$plugin_3'"}'
# Group 2.2
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_13_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_13_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_14_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_14_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_15_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_15_pd'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_16_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_16_pd'", "plugin": "'$plugin_1'"}'

# Create of south pipelines
curl -X PUT http://localhost:8081/fledge/filter/$s1_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_3'", "'$plugin_2'", "'$plugin_4'", "'$plugin_5'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s2_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_3'", "'$plugin_2'", "'$plugin_4'", "'$plugin_5'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s3_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s4_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'"]}'

# Create of north pipelines
curl -X PUT http://localhost:8081/fledge/filter/$n1_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n2_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n3_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n4_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n5_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n6_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n7_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n8_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'

# Create control pipelines
# Group 1.1
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n1_north_service_name'"},"destination":{"type":2,"name":"'$s1_south_service_name'"},"filters":["'$ctrl_filter_1_sp'","'$ctrl_filter_1_pd'"],"enabled":false,"name":"'$ctrl_pipeline_1'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n2_north_service_name'"},"destination":{"type":2,"name":"'$s1_south_service_name'"},"filters":["'$ctrl_filter_2_sp'","'$ctrl_filter_2_pd'"],"enabled":false,"name":"'$ctrl_pipeline_2'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n3_north_service_name'"},"destination":{"type":2,"name":"'$s1_south_service_name'"},"filters":["'$ctrl_filter_3_sp'","'$ctrl_filter_3_pd'"],"enabled":false,"name":"'$ctrl_pipeline_3'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n4_north_service_name'"},"destination":{"type":2,"name":"'$s1_south_service_name'"},"filters":["'$ctrl_filter_4_sp'","'$ctrl_filter_4_pd'"],"enabled":false,"name":"'$ctrl_pipeline_4'"}'
# Group 1.2
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n1_north_service_name'"},"destination":{"type":2,"name":"'$s3_south_service_name'"},"filters":["'$ctrl_filter_5_sp'","'$ctrl_filter_5_pd'"],"enabled":false,"name":"'$ctrl_pipeline_5'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n2_north_service_name'"},"destination":{"type":2,"name":"'$s3_south_service_name'"},"filters":["'$ctrl_filter_6_sp'","'$ctrl_filter_6_pd'"],"enabled":false,"name":"'$ctrl_pipeline_6'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n3_north_service_name'"},"destination":{"type":2,"name":"'$s3_south_service_name'"},"filters":["'$ctrl_filter_7_sp'","'$ctrl_filter_7_pd'"],"enabled":false,"name":"'$ctrl_pipeline_7'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n4_north_service_name'"},"destination":{"type":2,"name":"'$s3_south_service_name'"},"filters":["'$ctrl_filter_8_sp'","'$ctrl_filter_8_pd'"],"enabled":false,"name":"'$ctrl_pipeline_8'"}'
# Group 2.1
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n5_north_service_name'"},"destination":{"type":2,"name":"'$s2_south_service_name'"},"filters":["'$ctrl_filter_9_sp'","'$ctrl_filter_9_pd'"],"enabled":false,"name":"'$ctrl_pipeline_9'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n6_north_service_name'"},"destination":{"type":2,"name":"'$s2_south_service_name'"},"filters":["'$ctrl_filter_10_sp'","'$ctrl_filter_10_pd'"],"enabled":false,"name":"'$ctrl_pipeline_10'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n7_north_service_name'"},"destination":{"type":2,"name":"'$s2_south_service_name'"},"filters":["'$ctrl_filter_11_sp'","'$ctrl_filter_11_pd'"],"enabled":false,"name":"'$ctrl_pipeline_11'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n8_north_service_name'"},"destination":{"type":2,"name":"'$s2_south_service_name'"},"filters":["'$ctrl_filter_12_sp'","'$ctrl_filter_12_pd'"],"enabled":false,"name":"'$ctrl_pipeline_12'"}'
# Group 2.2
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n5_north_service_name'"},"destination":{"type":2,"name":"'$s4_south_service_name'"},"filters":["'$ctrl_filter_13_sp'","'$ctrl_filter_13_pd'"],"enabled":false,"name":"'$ctrl_pipeline_13'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n6_north_service_name'"},"destination":{"type":2,"name":"'$s4_south_service_name'"},"filters":["'$ctrl_filter_14_sp'","'$ctrl_filter_14_pd'"],"enabled":false,"name":"'$ctrl_pipeline_14'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n7_north_service_name'"},"destination":{"type":2,"name":"'$s4_south_service_name'"},"filters":["'$ctrl_filter_15_sp'","'$ctrl_filter_15_pd'"],"enabled":false,"name":"'$ctrl_pipeline_15'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n8_north_service_name'"},"destination":{"type":2,"name":"'$s4_south_service_name'"},"filters":["'$ctrl_filter_16_sp'","'$ctrl_filter_16_pd'"],"enabled":false,"name":"'$ctrl_pipeline_16'"}'

# Param advanced south
sleep 5
# setting south service max readings latency to 100 ms
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s3_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s4_south_service_name_advanced
# setting statistics to be collected at service level
curl -X PUT --data '{"statistics":"per service"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"statistics":"per service"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced
curl -X PUT --data '{"statistics":"per service"}' http://localhost:8081/fledge/category/$s3_south_service_name_advanced
curl -X PUT --data '{"statistics":"per service"}' http://localhost:8081/fledge/category/$s4_south_service_name_advanced
# setting audit tracker interval to 5 min
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$s3_south_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$s4_south_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n1_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n2_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n3_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n4_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n5_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n6_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n7_north_service_name_advanced
curl -X PUT --data '{"assetTrackerInterval":"9999999"}' http://localhost:8081/fledge/category/$n8_north_service_name_advanced

# Param storage layer
curl -X PUT --data '{"readingPlugin":"sqlitememory"}' http://localhost:8081/fledge/category/Storage

# Param purge
curl -X PUT --data '{"value":"1"}' http://localhost:8081/fledge/category/PURGE_READ/age
curl -X PUT --data '{"value":"100000"}' http://localhost:8081/fledge/category/PURGE_READ/size

# Create Notification plugins
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_1'","description":"'$notif_name_1' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":false,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_2'","description":"'$notif_name_2' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":false,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_3'","description":"'$notif_name_3' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":false,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_4'","description":"'$notif_name_4' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":false,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
# Workaround for delay between notifications (we want 0 but Fledge does not allow it, and -1 is rejected at notification instance creation)
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_1
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_2
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_3
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_4

# Restart Fledge as it is mandatory for control pipelines to work
curl -X PUT http://localhost:8081/fledge/restart
