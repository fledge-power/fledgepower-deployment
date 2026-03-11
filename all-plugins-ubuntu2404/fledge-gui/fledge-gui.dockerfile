# Stage build
FROM node:latest AS builder

ARG GITHEAD=v3.1.0

WORKDIR /app

RUN wget -O fledge-gui.tar.gz https://github.com/fledge-iot/fledge-gui/archive/refs/tags/$GITHEAD.tar.gz && tar -xf fledge-gui.tar.gz && mv fledge-gui-* fledge-gui

WORKDIR /app/fledge-gui

RUN bash build --clean-start

RUN mv dist /app

# Stage serve
FROM nginx:latest

COPY --from=builder /app/dist/* /usr/share/nginx/html

RUN mv /usr/share/nginx/html/fledge.html /usr/share/nginx/html/index.html

# Fledge GUI ports
EXPOSE 8080
