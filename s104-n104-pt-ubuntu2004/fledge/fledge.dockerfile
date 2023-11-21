FROM ubuntu:20.04

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform

ARG FLEDGEVERSION=2.2.0-25
ARG RELEASE=FOGL-8256
ARG OPERATINGSYSTEM=ubuntu2004
ARG ARCHITECTURE=x86_64
ARG FLEDGELINK="http://archives.fledge-iot.org/fixes/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"

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

########### FLEDGE ###########    
RUN mkdir ./fledge && \
    wget -O ./fledge/fledge-${FLEDGEVERSION}-${ARCHITECTURE}.deb --no-check-certificate ${FLEDGELINK}/fledge_${FLEDGEVERSION}_${ARCHITECTURE}.deb && \  
    dpkg --unpack ./fledge/fledge-${FLEDGEVERSION}-${ARCHITECTURE}.deb && \
    sed '/^.*_fledge_service$/d' /var/lib/dpkg/info/fledge.postinst > /fledge.postinst && \
    mv /var/lib/dpkg/info/fledge.postinst /var/lib/dpkg/info/fledge.postinst.save && \
    apt-get install -yf && \
    mkdir -p /usr/local/fledge/data/extras/fogbench && \
    chmod +x /fledge.postinst && \
    /fledge.postinst && \
    rm -f /*.tgz && \ 
    rm -rf -r /fledge && \
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

########### NORTH 104 ###########
COPY fledge-north-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-iec104_build.sh && \
    /tmp/fledge-north-iec104_build.sh && \
    echo '=============================================='

########### SOUTH 104 ###########
COPY fledge-south-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-iec104_build.sh && \
    /tmp/fledge-south-iec104_build.sh && \
    echo '=============================================='

########### NORTH SNMP ###########
COPY fledge-north-auditsnmp_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-auditsnmp_build.sh && \
    /tmp/fledge-north-auditsnmp_build.sh && \
    echo '=============================================='

########### PLUGIN 104 TO PIVOT ###########
#COPY fledgepower-filter-iec104topivot_build.sh /tmp/

#RUN chmod +x /tmp/fledgepower-filter-iec104topivot_build.sh && \
#    /tmp/fledgepower-filter-iec104topivot_build.sh && \
#    echo '=============================================='

########### PLUGIN TRANSIENT ###########
#COPY fledgepower-filter-transientsp_build.sh /tmp/

#RUN chmod +x /tmp/fledgepower-filter-transientsp_build.sh && \
#    /tmp/fledgepower-filter-transientsp_build.sh && \
#    echo '=============================================='

########### PLUGIN MVSCALE ###########
#COPY fledgepower-filter-mvscale_build.sh /tmp/

#RUN chmod +x /tmp/fledgepower-filter-mvscale_build.sh && \
#    /tmp/fledgepower-filter-mvscale_build.sh && \
#    echo '=============================================='

WORKDIR /usr/local/fledge

COPY importModules.sh importModules.sh
COPY start.sh start.sh

RUN chmod +x start.sh
VOLUME /usr/local/fledge 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 8090 1995 8080 2404 2405

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
