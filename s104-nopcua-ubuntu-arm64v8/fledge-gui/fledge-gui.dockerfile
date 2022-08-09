FROM arm64v8/nginx:latest

LABEL author="Akli Rahmoun"

ENV ARCHITECTURE="x86_64"
ENV FLEDGEVERSION="1.9.1"
ENV OPERATINGSYSTEM="ubuntu2004"
ENV FLEDGELINK="http://archives.fledge-iot.org/${FLEDGEVERSION}/${OPERATINGSYSTEM}/${ARCHITECTURE}"

RUN apt-get update

RUN apt-get install -y wget && \ 
    wget --no-check-certificate ${FLEDGELINK}/fledge-gui-${FLEDGEVERSION}.deb && \
    dpkg --unpack fledge-gui-${FLEDGEVERSION}.deb && \
    rm -r /usr/share/nginx/html && \
    mv /var/www/html /usr/share/nginx && \
    mv /usr/share/nginx/html/fledge.html /usr/share/nginx/html/index.html && \
    chown -R  nginx.nginx /usr/share/nginx/html && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/ && \
    rm -rf /var/www/

# Fledge GUI ports
EXPOSE 8080
