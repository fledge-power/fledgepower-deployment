#!/bin/bash

# Constants
s1_south_service_name="iec104south_s1"
s2_south_service_name="iec104south_s2"
s1_south_service_name_advanced="${s1_south_service_name}Advanced"
s2_south_service_name_advanced="${s2_south_service_name}Advanced"

n1_north_service_name="iec104north_c1"
n2_north_service_name="iec104north_c2"

plugin_1="iec104_pivot_filter"
plugin_2="status-points-timestamping"
plugin_3="transientsp"
plugin_4="mvscale"
plugin_5="mvcyclingcheck"

# Create service south
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s1_south_service_name'","type":"south","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s2_south_service_name'","type":"south","plugin":"iec104","enabled":false}'

# Create service north
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n1_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n2_north_service_name'","type":"north","plugin":"iec104","enabled":false}'

# Create plugins
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_4'", "plugin": "'$plugin_4'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_5'", "plugin": "'$plugin_5'"}'

# Create of south pipelines
curl -X PUT http://localhost:8081/fledge/filter/$s1_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'", "'$plugin_3'", "'$plugin_4'", "'$plugin_5'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s2_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'", "'$plugin_3'", "'$plugin_4'", "'$plugin_5'"]}'

# Create of north pipelines
curl -X PUT http://localhost:8081/fledge/filter/$n1_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n2_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'

# Param advanced south
sleep 5
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced

# Param purge
curl -X PUT --data '{"value":"1"}' http://localhost:8081/fledge/category/PURGE_READ/age
curl -X PUT --data '{"value":"100000"}' http://localhost:8081/fledge/category/PURGE_READ/size