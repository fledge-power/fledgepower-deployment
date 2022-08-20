FROM arm32v7/debian:bullseye

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform
ARG FLEDGEVERSION=1.9.2-946
ARG RELEASE=nightly
ARG OPERATINGSYSTEM=bullseye
ARG ARCHITECTURE=armv7l
ARG FLEDGELINK="http://archives.fledge-iot.org/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"
ARG IEC104_SOUTH_SERVICE_NAME=iec104south_t1
ARG OPCUA_NORTH_SERVICE_NAME=opcuanorth_t1
ARG SYSTEMINFO_SOUTH_SERVICE_NAME=systeminfosouth_t1

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
    cmake g++ make build-essential autoconf automake uuid-dev \
    software-properties-common lsb-release && \
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

RUN chmod +x /tmp/fledge-north-opcua_build.sh && \
    /tmp/fledge-north-opcua_build.sh && \
    echo '=============================================='

COPY fledge-south-systeminfo_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-systeminfo_build.sh && \
    /tmp/fledge-south-systeminfo_build.sh && \
    echo '=============================================='

COPY fledgepower-filter-iec104todp_build.sh /tmp/

RUN chmod +x /tmp/fledgepower-filter-iec104todp_build.sh && \
    /tmp/fledgepower-filter-iec104todp_build.sh && \
    echo '=============================================='

WORKDIR /usr/local/fledge
COPY start.sh start.sh

RUN echo "sleep 30" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${SYSTEMINFO_SOUTH_SERVICE_NAME}\",\"type\":\"south\",\"plugin\":\"systeminfo\",\"enabled\":false}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_SOUTH_SERVICE_NAME}\",\"type\":\"south\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${OPCUA_NORTH_SERVICE_NAME}\",\"type\":\"north\",\"plugin\":\"opcua\",\"enabled\":false}'" >> start.sh && \
    echo "tail -f /var/log/syslog" >> start.sh && \
    chmod +x start.sh

VOLUME /usr/local/fledge 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 1995 8080 4840

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
