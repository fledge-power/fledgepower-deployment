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
## Author: Akli Rahmoun
##

echo "TASE REPO ACCESS TOKEN: $TASE2_REPO_ACCESS_TOKEN"

# Set the YAML file
yaml_file="buildContainerfile.yml"

# Set the Dockerfiles
dockerfile="fledge.dockerfile"
dockerfiletemplate="fledge.template.dockerfile"

# Copy the static content from the Dockerfile template
cp $dockerfiletemplate $dockerfile

# Set the YAML file for Sonar report
pmcfile="pmc.yml"
# Create the file or empty it
echo -n "" > $pmcfile

# Read configuration values
FLEDGEVERSION=$(yq e '.fledge.version' "$yaml_file")
RELEASE=$(yq e '.fledge.release' "$yaml_file")
GITHEAD=$(yq e '.fledge.githead' "$yaml_file")
OPERATINGSYSTEM=$(yq e '.fledge.operatingsystem' "$yaml_file")
ARCHITECTURE=$(yq e '.fledge.architecture' "$yaml_file")
FLEDGEDISPATCHERVERSION=$(yq e '.fledge.dispatcherversion' "$yaml_file")
FLEDGENOTIFVERSION=$(yq e '.fledge.notifversion' "$yaml_file")

# Update Containerfile args values
sed -i "s/ARG FLEDGEVERSION=.*/ARG FLEDGEVERSION=\"$FLEDGEVERSION\"/" $dockerfile
sed -i "s|ARG RELEASE=.*|ARG RELEASE=\"$RELEASE\"|" $dockerfile
sed -i "s|ARG GITHEAD=.*|ARG GITHEAD=\"$GITHEAD\"|" $dockerfile
sed -i "s/ARG OPERATINGSYSTEM=.*/ARG OPERATINGSYSTEM=\"$OPERATINGSYSTEM\"/" $dockerfile
sed -i "s/ARG ARCHITECTURE=.*/ARG ARCHITECTURE=\"$ARCHITECTURE\"/" $dockerfile
sed -i "s/ARG FLEDGEDISPATCHERVERSION=.*/ARG FLEDGEDISPATCHERVERSION=\"$FLEDGEDISPATCHERVERSION\"/" $dockerfile
sed -i "s/ARG FLEDGENOTIFVERSION=.*/ARG FLEDGENOTIFVERSION=\"$FLEDGENOTIFVERSION\"/" $dockerfile

sed -i "s/ENV TASE2_REPO_ACCESS_TOKEN=.*/ENV TASE2_REPO_ACCESS_TOKEN=\"$TASE2_REPO_ACCESS_TOKEN\"/" $dockerfile

# Get the latest tag version
pmc_version=$(git describe --tags --abbrev=0)

# Start Sonar configuration
yq '.application.name = "PMC - Passerelle Multi Centre"' -i $pmcfile
yq '.application.version = "'$pmc_version'"' -i $pmcfile

# Set the start marker
start_marker="# INSERT MODULES TO BUILD HERE"

# Get the list of modules
module_names=$(yq eval '.build_modules[].module.name' "$yaml_file")
module_versions=$(yq eval '.build_modules[].module.version' "$yaml_file")

i=0
j=0

# Iterate over modules list
for module in $module_names; do

  ((i++))

  # Extract the module name and version
  module_name=$(echo "$module_names" | cut -d$'\n' -f$i)
  module_version=$(echo "$module_versions" | cut -d$'\n' -f$i)

  # Generate the Docker instructions
  docker_instructions="COPY $module_name /tmp/$module_name\nRUN chmod +x /tmp/$module_name && /tmp/$module_name $module_version\n"

  # Insert the Docker instructions into the Dockerfile
  sed -i "/$start_marker/a $docker_instructions" "$dockerfile"

  # Add only fledge-power lib except fledgepower-filter-opcuatopivot and fledge-north-auditsnmp
  if [[ $module_name = "fledge"* && $module_name != "fledgepower-filter-pivottoopcua"* && $module_name != "fledge-north-auditsnmp"* ]]
  then
    # Extract the module name without its extension
    name=$(echo $module_name | cut -d_ -f1)

    project_key="fledge-power_"$name
    type="backend"
    sonar_config="SonarCloud"

    # Add the plugin to the yaml file
    yq '.application.modules['$j'].name = "'"${name//-/ }"'"' -i $pmcfile
    yq '.application.modules['$j'].project_key = "'$project_key'"' -i $pmcfile 
    yq '.application.modules['$j'].branch = "'$module_version'"' -i $pmcfile
    yq '.application.modules['$j'].type = "'$type'"' -i $pmcfile
    yq '.application.modules['$j'].sonar_config = "'$sonar_config'"' -i $pmcfile

    ((j++))
  fi 

done

# Read ports values from conf file
mapfile -t ports < <(yq eval '.ports[]' "$yaml_file")

# Update the EXPOSE part in the fledge.dockerfile
sed -i "s/EXPOSE .*/EXPOSE ${ports[*]}/" "$dockerfile"

