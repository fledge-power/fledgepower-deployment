FROM ubuntu:20.04

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform
ARG FLEDGEVERSION=2.0.1
ARG RELEASE=2.0.1 
ARG OPERATINGSYSTEM=ubuntu2004
ARG ARCHITECTURE=x86_64
ARG FLEDGELINK="http://archives.fledge-iot.org/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"
ARG IEC104_SOUTH_SERVICE_NAME=iec104south_s1
ARG OPCUA_NORTH_SERVICE_NAME=opcuanorth_c1
ARG IEC104TOPIVOT_FILTER_NAME=iec104topivot_filter
ARG PIVOTTOOPCUA_FILTER_NAME=pivottoopcua_filter

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
    sysstat \
    cmake g++ make build-essential autoconf automake uuid-dev && \
    echo '=============================================='
    
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

RUN chmod +x /tmp/fledge-install-include.sh && \
    /tmp/fledge-install-include.sh && \
    echo '=============================================='

COPY fledge-install-dispatcher.sh /tmp/

RUN chmod +x /tmp/fledge-install-dispatcher.sh && \
    /tmp/fledge-install-dispatcher.sh && \
    echo '=============================================='

COPY fledge-south-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-iec104_build.sh && \
    /tmp/fledge-south-iec104_build.sh && \
    echo '=============================================='

COPY fledge-north-opcua_build.sh /tmp/

ENV FLEDGE_N_S2OPCUA_BRANCH=main
RUN chmod +x /tmp/fledge-north-opcua_build.sh && \
    /tmp/fledge-north-opcua_build.sh && \
    echo '=============================================='

COPY fledgepower-filter-iec104topivot_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-iec104topivot_build.sh && \
    /tmp/fledgepower-filter-iec104topivot_build.sh && \
    echo '=============================================='

COPY fledgepower-filter-pivottoopcua_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-pivottoopcua_build.sh && \
    /tmp/fledgepower-filter-pivottoopcua_build.sh && \
    echo '=============================================='

WORKDIR /usr/local/fledge
COPY start.sh start.sh

RUN echo "sleep 30" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_SOUTH_SERVICE_NAME}\",\"type\":\"south\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${OPCUA_NORTH_SERVICE_NAME}\",\"type\":\"north\",\"plugin\":\"opcua\",\"enabled\":false}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/filter -d '{\"name\":\"${IEC104TOPIVOT_FILTER_NAME}\",\"plugin\":\"iec104_pivot_filter\"}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/filter -d '{\"name\":\"${PIVOTTOOPCUA_FILTER_NAME}\",\"plugin\":\"pivottoopcua\"}'" >> start.sh && \
    echo "curl -sX PUT http://localhost:8081/fledge/filter/${IEC104_SOUTH_SERVICE_NAME}/pipeline -d  '{\"pipeline\":[\"${IEC104TOPIVOT_FILTER_NAME}\"]}'" >> start.sh && \
    echo "curl -sX PUT http://localhost:8081/fledge/filter/${OPCUA_NORTH_SERVICE_NAME}/pipeline -d  '{\"pipeline\":[\"${PIVOTTOOPCUA_FILTER_NAME}\"]}'" >> start.sh && \
    echo "tail -f /var/log/syslog" >> start.sh && \
    chmod +x start.sh

VOLUME /usr/local/fledge 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 1995 8080 4840

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
