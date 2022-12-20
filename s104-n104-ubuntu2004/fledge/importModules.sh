#!/bin/bash

# Constants
nom_service_south_s1="iec104south_s1"
nom_service_south_s2="iec104south_s2"
nom_service_south_s1_advanced="${nom_service_south_s1}Advanced"
nom_service_south_s2_advanced="${nom_service_south_s2}Advanced"

nom_service_north_n1="iec104north_c1"
nom_service_north_n2="iec104north_c2"

plugin_1="iec104_pivot_filter"
plugin_2="status-points-timestamping"
plugin_3="transientsp"
plugin_4="mvscale"
plugin_5="mvcyclingcheck"

# Create service south
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$nom_service_south_s1'","type":"south","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$nom_service_south_s2'","type":"south","plugin":"iec104","enabled":false}'

# Create service north
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$nom_service_north_n1'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$nom_service_north_n2'","type":"north","plugin":"iec104","enabled":false}'

# Create plugins
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_4'", "plugin": "'$plugin_4'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_5'", "plugin": "'$plugin_5'"}'

# Create of south pipelines
curl -X PUT http://localhost:8081/fledge/filter/$nom_service_south_s1/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'", "'$plugin_3'", "'$plugin_4'", "'$plugin_5'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$nom_service_south_s2/pipeline -d  '{"pipeline": ["'$plugin_1'", "'$plugin_2'", "'$plugin_3'", "'$plugin_4'", "'$plugin_5'"]}'

# Create of north pipelines
curl -X PUT http://localhost:8081/fledge/filter/$nom_service_north_n1/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$nom_service_north_n2/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'

# Param advanced south
sleep 5
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$nom_service_south_s1_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$nom_service_south_s2_advanced