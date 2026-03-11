# Stage build
FROM node:latest AS builder

ARG GITHEAD=v3.1.0

WORKDIR /app

RUN wget -O fledge-gui.tar.gz https://github.com/fledge-iot/fledge-gui/archive/refs/tags/$GITHEAD.tar.gz && tar -xf fledge-gui.tar.gz && mv fledge-gui-* fledge-gui

WORKDIR /app/fledge-gui

RUN yarn install && yarn build

RUN mv dist /app

RUN cp docker/nginx-docker.conf ../nginx.conf

# Stage serve
FROM nginx:latest

COPY --from=builder /app/dist/* /usr/share/nginx/html

COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf

# Fledge GUI ports
EXPOSE 8080
