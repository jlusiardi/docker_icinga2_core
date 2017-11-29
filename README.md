# docker_icinga2_core

## Requirements

 * access to icinga ido database
 * access to smtp smarthost for sending notifications
 * **optional**: access to a graphite container
 
## Start

First make sure the ido database exists:

```
docker run -d \
           --name icinga_ido_db \
           -e MYSQL_ROOT_PASSWORD=$ROOT_PWD \ 
           -e MYSQL_USER=icinga \ 
           -e MYSQL_PASSWORD=icinga \ 
           -e MYSQL_DATABASE=icinga \
           -v $DIR_ON_HOST:/var/lib/mysql
           mysql:5.7
```
           
Initialize the ido db on first run:
```
docker run -ti \ 
           --rm \
           --link icinga_ido_db:mysql_ido \
           docker_icinga2_core init
```

The icinga config can be checked with:
```
docker run -ti \
           --rm \
           -v $DIR_ON_HOST:/etc/icinga2/conf.d \ 
           docker_icinga2_core check
```

Run container:
```
docker run -d \
           --name icinga2_core \ 
           -e SMARTHOST_HOST=$HOSTNAME::587 \ 
           -e SMARTHOST_USER=$USER \
           -e SMARTHOST_PASSWORD=$PASSWORD \ 
           -e SMARTHOST_MAILNAME=$DOMAIN \
           -v $DIR_ON_HOST:/etc/icinga2/conf.d \ 
           --link graphite:graphite \
           -e FEATURE_GRAPHITE=on \
           --link icinga_db:mysql_ido \
           -e API_PASSWD=$API_PASSWD
           docker_icinga2_core
```

The environment variables **API_PASSWD** and **FEATURE_GRAPHITE** are optional and if omitted 
deactivate those features.  

## Notes
The file **icinga.key** was taken from http://packages.icinga.com/icinga.key.