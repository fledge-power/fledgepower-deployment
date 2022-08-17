#!/bin/bash

# Unprivileged Docker containers do not have access to the kernel log. This prevents an error when starting rsyslogd.
sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

service rsyslog start
/usr/local/fledge/bin/fledge start
