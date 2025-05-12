#!/bin/bash

# Constants
s1_south_service_name="hnzsouth_s1"
s2_south_service_name="hnzsouth_s2"
s1_south_service_name_advanced="${s1_south_service_name}Advanced"
s2_south_service_name_advanced="${s2_south_service_name}Advanced"

n1_north_service_name="iec104north_c1"
n2_north_service_name="iec104north_c2"

snmp_north_service_name="auditsnmpnorth"

plugin_1="iec104_pivot_filter"
plugin_2="transientsp"
plugin_3="hnz_pivot_filter"
plugin_4="mvscale"

name_service_notif="notif"
notif_plugin_1="systemspr"
notif_plugin_2="systemspn"
notif_name_1='systemsp'

ctrl_pipeline_1="${n1_north_service_name}_to_${s1_south_service_name}"
ctrl_pipeline_2="${n2_north_service_name}_to_${s2_south_service_name}"

ctrl_filter_1_sp="${ctrl_pipeline_1}_source_to_pivot_filter"
ctrl_filter_1_pd="${ctrl_pipeline_1}_pivot_to_destination_filter"
ctrl_filter_2_sp="${ctrl_pipeline_2}_source_to_pivot_filter"
ctrl_filter_2_pd="${ctrl_pipeline_2}_pivot_to_destination_filter"

# Create service south
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s1_south_service_name'","type":"south","plugin":"hnz","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s2_south_service_name'","type":"south","plugin":"hnz","enabled":false}'

# Create service north
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n1_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n2_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$snmp_north_service_name'","type":"north","plugin":"auditsnmp","enabled":false}'

# Create service notification
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$name_service_notif'","type":"notification","enabled":true}'

# Create plugins
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s1_south_service_name'_'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s1_south_service_name'_'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s1_south_service_name'_'$plugin_4'", "plugin": "'$plugin_4'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s2_south_service_name'_'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s2_south_service_name'_'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$s2_south_service_name'_'$plugin_4'", "plugin": "'$plugin_4'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$n1_north_service_name'_'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$n2_north_service_name'_'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_1_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_1_pd'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_2_sp'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$ctrl_filter_2_pd'", "plugin": "'$plugin_3'"}'

# Create of south pipelines
curl -X PUT http://localhost:8081/fledge/filter/$s1_south_service_name/pipeline -d  '{"pipeline": ["'$s1_south_service_name'_'$plugin_3'", "'$s1_south_service_name'_'$plugin_2'", "'$s1_south_service_name'_'$plugin_4'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s2_south_service_name/pipeline -d  '{"pipeline": ["'$s2_south_service_name'_'$plugin_3'", "'$s2_south_service_name'_'$plugin_2'", "'$s2_south_service_name'_'$plugin_4'"]}'

# Create of north pipelines
curl -X PUT http://localhost:8081/fledge/filter/$n1_north_service_name/pipeline -d  '{"pipeline": ["'$n1_north_service_name'_'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n2_north_service_name/pipeline -d  '{"pipeline": ["'$n2_north_service_name'_'$plugin_1'"]}'

# Create control pipelines
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n1_north_service_name'"},"destination":{"type":2,"name":"'$s1_south_service_name'"},"filters":["'$ctrl_filter_1_sp'","'$ctrl_filter_1_pd'"],"enabled":true,"name":"'$ctrl_pipeline_1'"}'
curl -sX POST http://localhost:8081/fledge/control/pipeline -d '{"execution":"Shared","source":{"type":2,"name":"'$n2_north_service_name'"},"destination":{"type":2,"name":"'$s2_south_service_name'"},"filters":["'$ctrl_filter_2_sp'","'$ctrl_filter_2_pd'"],"enabled":true,"name":"'$ctrl_pipeline_2'"}'

# Param advanced south
sleep 5
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced
curl -X PUT --data '{"statistics":"per service"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced

# Param storage layer
curl -X PUT --data '{"readingPlugin":"sqlitememory"}' http://localhost:8081/fledge/category/Storage

# Param purge
curl -X PUT --data '{"value":"1"}' http://localhost:8081/fledge/category/PURGE_READ/age
curl -X PUT --data '{"value":"100000"}' http://localhost:8081/fledge/category/PURGE_READ/size

# Create Notification plugins
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_1'","description":"'$notif_name_1' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":true,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
# Workaround for delay between notifications (we want 0 but Fledge does not allow it, and -1 is rejected at notification instance creation)
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_1

# Restart Fledge as it is mandatory for control pipelines to work
curl -X PUT http://localhost:8081/fledge/restart
