FROM ubuntu:20.04

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform
ARG FLEDGEVERSION=2.0.0-40
ARG RELEASE=nightly 
ARG OPERATINGSYSTEM=ubuntu2004
ARG ARCHITECTURE=x86_64
ARG FLEDGELINK="http://archives.fledge-iot.org/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"
ARG IEC104_SOUTH_SERVICE_NAME=iec104south_t1
ARG IEC104_NORTH_SERVICE_NAME=iec104north_t1

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
    cmake g++ make build-essential autoconf automake uuid-dev && \
    echo '=============================================='
    
COPY fledge-install-include.sh /tmp/

RUN chmod +x /tmp/fledge-install-include.sh && \
    /tmp/fledge-install-include.sh && \
    echo '=============================================='
    
COPY fledge-install-fromdev.sh /tmp/

RUN chmod +x /tmp/fledge-install-fromdev.sh && \
    /tmp/fledge-install-fromdev.sh && \
    echo '=============================================='

COPY fledge-install-dispatcher.sh /tmp/

RUN chmod +x /tmp/fledge-install-dispatcher.sh && \
    /tmp/fledge-install-dispatcher.sh && \
    echo '=============================================='

COPY fledge-south-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-iec104_build.sh && \
    /tmp/fledge-south-iec104_build.sh && \
    echo '=============================================='

COPY fledge-north-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-iec104_build.sh && \
    /tmp/fledge-north-iec104_build.sh && \
    echo '=============================================='

WORKDIR /usr/local/fledge
COPY start.sh start.sh

RUN echo "sleep 30" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_SOUTH_SERVICE_NAME}\",\"type\":\"south\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_NORTH_SERVICE_NAME}\",\"type\":\"north\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "tail -f /var/log/syslog" >> start.sh && \
    chmod +x start.sh

VOLUME /usr/local/fledge 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 1995 8080 2404

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
