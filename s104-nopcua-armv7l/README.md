# fledgepower-deploy
Run Fledge with IEC 104 south and north plugins and Fledge-GUI as containers under Docker using docker-compose

### Run app

Launch app in deamon mode 
```
    $ sudo docker-compose up -d
```
Navigate to http://localhost:8080 to check the Fledge web UI

Test admin REST API
```
    $ curl -s http://localhost:8081/fledge/ping | jq
```
Test south and north services are up and running
```
    $ curl -sX GET http://localhost:8081/fledge/service | jq
```
