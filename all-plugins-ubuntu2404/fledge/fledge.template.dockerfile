FROM ubuntu:24.04

LABEL author="Akli Rahmoun"

ARG GITHEAD=GITHEAD

ENV TASE2_REPO_ACCESS_TOKEN=TASE2_REPO_ACCESS_TOKEN
ENV LIB_HNZ="/usr/local/hnz/libhnz"

# Avoid interactive questions when installing Kerberos
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends --yes \
    sudo \
    git \
    iputils-ping \
    inetutils-telnet \
    nano \
    rsyslog \
    sed \
    wget \
    snmp \
    jq \
    cmake g++ make build-essential autoconf automake uuid-dev \
    libgtest-dev libgmock-dev \
    libssl-dev \
    avahi-daemon ca-certificates curl libcurl4-openssl-dev \
    libtool libboost-dev libboost-system-dev libboost-thread-dev libpq-dev libz-dev \
    libsqlite3-dev sqlite3 \
    pkg-config \
    python-dev-is-python3 python3-dev python3-pip python3-numpy && \
    echo '=============================================='

COPY fledge_build.sh /tmp/
RUN bash /tmp/fledge_build.sh ${GITHEAD} && \
    echo '=============================================='

ENV FLEDGE_ROOT=/usr/local/fledge

COPY fledge-service-dispatcher_build.sh /tmp/
RUN bash /tmp/fledge-service-dispatcher_build.sh ${GITHEAD} && \
    echo '=============================================='

COPY fledge-service-notification_build.sh /tmp/
RUN bash /tmp/fledge-service-notification_build.sh ${GITHEAD} && \
    echo '=============================================='

# Hotfix for uppercase ssl certificate, can be removed after integrating Fledge >= 2.7.0 (including commit 9d8bc89)
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
