FROM ubuntu:20.04

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform
ARG FLEDGEVERSION=2.3.0-95
ARG RELEASE=nightly
ARG OPERATINGSYSTEM=ubuntu2004
ARG ARCHITECTURE=x86_64
ARG FLEDGELINK="http://archives.fledge-iot.org/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"

ENV FLEDGE_ROOT=/usr/local/fledge

# Avoid interactive questions when installing Kerberos
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends --yes \
    git \
    iputils-ping \
    inetutils-telnet \
    nano \
    rsyslog \
    sed \
    wget \
    snmp \
    cmake g++ make build-essential autoconf automake uuid-dev && \
    echo '=============================================='
    
RUN mkdir ./fledge && \
    wget -O ./fledge/fledge-${FLEDGEVERSION}-${ARCHITECTURE}.deb --no-check-certificate ${FLEDGELINK}/fledge_${FLEDGEVERSION}_${ARCHITECTURE}.deb && \
    #
    # The postinstall script of the .deb package enables and starts the fledge service. Since services are not supported in docker
    # containers, we must modify the postinstall script to remove these lines so that the package will install without errors.
    # We will manually unpack the file, use sed to remove the offending lines, and then run 'apt-get install -yf' to install the 
    # package and the dependancies. Once the package is successfully installed, all of the service and plugin package
    # will install normally.
    #
    # Unpack .deb package    
    dpkg --unpack ./fledge/fledge-${FLEDGEVERSION}-${ARCHITECTURE}.deb && \
    # Remove lines that enable and start the service. They call enable_FLEDGE_service() and start_FLEDGE_service()
    # Save to /fledge.postinst. We'll run that after we install the dependencies.
    sed '/^.*_fledge_service$/d' /var/lib/dpkg/info/fledge.postinst > /fledge.postinst && \
    # Rename the original file so that it doesn't get run in next step.
    mv /var/lib/dpkg/info/fledge.postinst /var/lib/dpkg/info/fledge.postinst.save && \
    # Configure the package and install dependencies.
    apt-get install -yf && \
    # Manually run the post install script - creates certificates, installs python dependencies etc.
    mkdir -p /usr/local/fledge/data/extras/fogbench && \
    chmod +x /fledge.postinst && \
    /fledge.postinst && \
    # Cleanup fledge installation packages
    rm -f /*.tgz && \ 
    # You may choose to leave the installation packages in the directory in case you need to troubleshoot
    rm -rf -r /fledge && \
    # General cleanup after using apt-get
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt-get/lists/ && \
    echo '=============================================='
    
COPY fledge-install-include.sh /tmp/
COPY versions.sh /tmp/

RUN chmod +x /tmp/fledge-install-include.sh && \
    /tmp/fledge-install-include.sh && \
    echo '=============================================='

COPY fledge-install-dispatcher.sh /tmp/

RUN chmod +x /tmp/fledge-install-dispatcher.sh && \
    /tmp/fledge-install-dispatcher.sh && \
    echo '=============================================='

########### NOTIFICATION ###########
COPY fledge-install-notification.sh /tmp/

RUN chmod +x /tmp/fledge-install-notification.sh && \
    /tmp/fledge-install-notification.sh && \
    echo '=============================================='

########### SNMP ###########
COPY fledge-north-auditsnmp_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-auditsnmp_build.sh && \
    /tmp/fledge-north-auditsnmp_build.sh && \
    echo '=============================================='

########### SOUTH HNZ ###########
COPY fledge-south-hnz_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-hnz_build.sh && \
    /tmp/fledge-south-hnz_build.sh && \
    echo '=============================================='

########### NORTH 104 ###########
COPY fledge-north-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-iec104_build.sh && \
    /tmp/fledge-north-iec104_build.sh && \
    echo '=============================================='

########### NORTH AUDITSNMP ###########
COPY fledge-north-auditsnmp_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-auditsnmp_build.sh && \
    /tmp/fledge-north-auditsnmp_build.sh && \
    echo '=============================================='

########### PLUGINS TRADUCTION 104 ###########
COPY fledgepower-filter-iec104topivot_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-iec104topivot_build.sh && \
    /tmp/fledgepower-filter-iec104topivot_build.sh && \
    echo '=============================================='

########### PLUGINS TRADUCTION HNZ ###########
COPY fledgepower-filter-hnztopivot_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-hnztopivot_build.sh && \
    /tmp/fledgepower-filter-hnztopivot_build.sh && \
    echo '=============================================='
    
########### PLUGIN TRANSIENTSP ###########
COPY fledgepower-filter-transientsp_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-transientsp_build.sh && \
    /tmp/fledgepower-filter-transientsp_build.sh && \
    echo '=============================================='

########### PLUGINS MVSCALE ###########
COPY fledgepower-filter-mvscale_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-mvscale_build.sh && \
    /tmp/fledgepower-filter-mvscale_build.sh && \
    echo '=============================================='

########### PLUGINS NOTIF SYSTEMSP ###########
COPY fledgepower-notify-systemsp_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-notify-systemsp_build.sh && \
    /tmp/fledgepower-notify-systemsp_build.sh && \
    echo '=============================================='


ADD fledgepower-rule-systemsp_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-rule-systemsp_build.sh && \
    /tmp/fledgepower-rule-systemsp_build.sh && \
    echo '=============================================='

WORKDIR /usr/local/fledge

COPY importModules.sh importModules.sh
COPY start.sh start.sh

RUN chmod +x start.sh
VOLUME /usr/local/fledge 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 8090 1995 8080 2404 2405 6001 6002

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
