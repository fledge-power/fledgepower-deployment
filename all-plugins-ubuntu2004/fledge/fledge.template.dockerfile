FROM ubuntu:20.04

LABEL author="Akli Rahmoun"

# Set FLEDGE version, distribution, and platform
ARG FLEDGEVERSION=FLEDGEVERSION
ARG RELEASE=RELEASE
ARG GITHEAD=GITHEAD
ARG OPERATINGSYSTEM=OPERATINGSYSTEM
ARG ARCHITECTURE=ARCHITECTURE
ARG FLEDGEDISPATCHERVERSION=FLEDGEDISPATCHERVERSION
ARG FLEDGENOTIFVERSION=FLEDGENOTIFVERSION
ARG FLEDGELINK="http://archives.fledge-iot.org/${RELEASE}/${OPERATINGSYSTEM}/${ARCHITECTURE}"

ENV FLEDGE_ROOT=/usr/local/fledge
ENV LIB_HNZ="/usr/local/hnz/libhnz"

ENV TASE2_REPO_ACCESS_TOKEN=TASE2_REPO_ACCESS_TOKEN

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
    cmake g++ make build-essential autoconf automake uuid-dev \
    libgtest-dev libgmock-dev && \
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
    /tmp/fledge-install-include.sh ${GITHEAD} && \
    echo '=============================================='

COPY fledge-install-dispatcher.sh /tmp/

RUN chmod +x /tmp/fledge-install-dispatcher.sh && \
    /tmp/fledge-install-dispatcher.sh ${FLEDGEDISPATCHERVERSION} ${RELEASE} ${OPERATINGSYSTEM} ${ARCHITECTURE} && \
    echo '=============================================='

COPY fledge-install-notification.sh /tmp/

RUN chmod +x /tmp/fledge-install-notification.sh && \
    /tmp/fledge-install-notification.sh ${FLEDGENOTIFVERSION} ${RELEASE} ${OPERATINGSYSTEM} ${ARCHITECTURE} && \
    echo '=============================================='

# Hotfix for uppercase ssl certificate
RUN sed -i '/username =.*commonName/ s/ *$/.lower()/' "/usr/local/fledge/python/fledge/services/core/api/auth.py"

# INSERT MODULES TO BUILD HERE

WORKDIR /usr/local/fledge

COPY importModules.sh importModules.sh
COPY start.sh start.sh

# REMOVE SOURCES IN /tmp
RUN rm -rf /tmp/*

RUN chmod +x start.sh
VOLUME /usr/local/fledge 

# INSERT PORT LIST HERE
EXPOSE 8081 8090 1995 8080 2404 2405 6001 6002

# start rsyslog, FLEDGE, and tail syslog
CMD ["/bin/bash","/usr/local/fledge/start.sh"]
