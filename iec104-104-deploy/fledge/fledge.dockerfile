FROM rsyslog/rsyslog_base_centos7:latest

LABEL author="Akli Rahmoun"

ARG ARCHITECTURE="x86_64"
ARG FLEDGEVERSION="1.9.2"
ARG OPERATINGSYSTEM="centos7"
ARG FLEDGELINK="http://archives.fledge-iot.org/${FLEDGEVERSION}/${OPERATINGSYSTEM}/${ARCHITECTURE}"
ARG IEC104_SOUTH_SERVICE_NAME=iec104south_t1
ARG IEC104_NORTH_SERVICE_NAME=iec104north_t1

ENV FLEDGE_ROOT=/usr/local/fledge

COPY fledge_build.sh /tmp/

RUN chmod +x /tmp/fledge_build.sh && \
    /tmp/fledge_build.sh && \
    echo '=============================================='

RUN wget ${FLEDGELINK}/fledge-${FLEDGEVERSION}-1.${ARCHITECTURE}.rpm && \
    rpm -ivh fledge-${FLEDGEVERSION}-1.${ARCHITECTURE}.rpm && \
    echo '=============================================='

COPY include /usr/local/fledge/include

COPY fledge-south-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-south-iec104_build.sh && \
    /tmp/fledge-south-iec104_build.sh && \
    echo '=============================================='

COPY fledge-north-iec104_build.sh /tmp/

RUN chmod +x /tmp/fledge-north-iec104_build.sh && \
    /tmp/fledge-north-iec104_build.sh && \
    echo '=============================================='

RUN echo "systemctl start rsyslog" > start.sh && \
    echo "/usr/local/fledge/bin/fledge start" >> start.sh && \
    echo "sleep 30" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_SOUTH_SERVICE_NAME}\",\"type\":\"south\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "sleep 10" >> start.sh && \
    echo "curl -sX POST http://localhost:8081/fledge/service -d '{\"name\":\"${IEC104_NORTH_SERVICE_NAME}\",\"type\":\"north\",\"plugin\":\"iec104\",\"enabled\":false}'" >> start.sh && \
    echo "tail -f /dev/null" >> start.sh && \
    chmod +x start.sh

# Fledge API ports
EXPOSE 8081 1995 6683 2404

CMD ["/bin/bash", "./start.sh"]
