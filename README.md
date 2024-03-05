# fledgepower-deployment
Containing all the needed components for deploying FledgePower services.

## deployment using all-plugins-ubuntu2004

### Dynamic container generation from YAML Configuration
This shell script (`buildContainerfile.sh`) is designed to generate a Dockerfile based on the configurations provided in a YAML file (`buildContainerfile.yml`). Here's a breakdown of what the script does:
1. It sets variables for the Dockerfile (`dockerfile`) and its template (`dockerfiletemplate`), as well as the YAML file (`yaml_file`).
2. Copies the content of the Dockerfile template to the Dockerfile.
3. Reads various configuration values from the YAML file using `yq` (a tool for processing YAML files).
4. Updates arguments in the Dockerfile (`$dockerfile`) with the values read from the YAML file using `sed`.
5. Sets a marker in the Dockerfile for where modules will be inserted.
6. Retrieves a list of module names and versions from the YAML file using `yq`.
7. Iterates over the list of modules, generating Docker instructions for each module and inserting them into the Dockerfile at the specified marker using `sed`.
8. Reads port values from the YAML file.
9. Updates the `EXPOSE` instruction in the Dockerfile with the ports read from the YAML file using `sed`.
In summary, the script dynamically generates a Dockerfile based on the configurations specified in the YAML file, including module names, versions, and port configurations.

### Structure of the "buildContainerfile.yml"
The structure of the "buildContainerfile.yml" file consists of various sections:
1. Version: Indicates the version of the YAML configuration file.
2. Fledge: Contains details about the Fledge application, including its version, release type, operating system, architecture, dispatcher service version, and notification service version.
3. Build Modules: Lists modules to be included in the build process. Each module has a name and version specified. The modules listed include scripts for building various components or functionalities related to Fledge.
4. Ports: Specifies a list of ports to be exposed. These ports are presumably used by the Fledge application or its modules for communication or networking purposes.
This structure organizes the configuration information required for building the Docker image effectively.

### Module building
Each module is built using a dedicated shell script named after the name of the module or plugin, where the desired version is passed as a parameter to the script in the Dockerfile.

### Modules instanciation and Fledge parameters set up
The script (`importModules.sh`) facilitates the instantiation of desired modules and sets core parameters for Fledge.
