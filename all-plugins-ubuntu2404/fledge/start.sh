#!/bin/bash

# Unprivileged Docker containers do not have access to the kernel log. This prevents an error when starting rsyslogd.
sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# Ubuntu 24.04 minimal does not have any service manager, start rsyslogd by calling the binary
rsyslogd

/usr/local/fledge/bin/fledge -u admin -p fledge start
sleep 10

password_token=$(curl -X POST http://localhost:8081/fledge/login -d'{"username" : "admin",  "password" : "fledge"}' | jq -r ".token" 2>/dev/null)
if [ ! -z "$password_token" ]; then
    curl -X PUT http://localhost:8081/fledge/category/rest_api -d '{"authentication":"optional"}' -H "authorization: $password_token"
fi

# Redémarrage
/usr/local/fledge/bin/fledge -u admin -p fledge stop
/usr/local/fledge/bin/fledge start

sleep 10
sh importModules.sh
tail -f /var/log/syslog