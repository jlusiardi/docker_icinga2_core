#!/bin/bash 

MODE=$1

if [ "$MODE" == "init" ]; then
    echo "*************************"
    echo "*    initializing...    *"
    echo "*************************"
    DB_UTIL="mysql -u root -p$MYSQL_IDO_ENV_MYSQL_ROOT_PASSWORD -h mysql_ido $MYSQL_IDO_ENV_MYSQL_DATABASE"
    ${DB_UTIL} < /usr/share/icinga2-ido-mysql/schema/mysql.sql
elif [ "$MODE" == "check" ]; then
    icinga2 daemon -c /etc/icinga2/icinga2.conf -C
else
    echo "**********************"
    echo "*    prepare mail    *"
    echo "**********************"
    HOST=`echo ${SMARTHOST_HOST} | sed 's/:.*//'`
	echo ${SMARTHOST_MAILNAME} > /etc/mailname
	echo "${HOST}:${SMARTHOST_USER}:${SMARTHOST_PASSWORD}" > /etc/exim4/passwd.client
	sed -i "s/__SMARTHOST__/${SMARTHOST_HOST}/" /etc/exim4/update-exim4.conf.conf
	/etc/init.d/exim4 start

    if [[ ! -z ${FEATURE_GRAPHITE} ]]
    then
        echo "**************************"
        echo "*    prepare graphite    *"
        echo "**************************"
        icinga2 feature enable graphite
	icinga2 feature enable perfdata 
    fi

    if [[ ! -z ${API_PASSWD} ]]
    then
        echo "*********************"
        echo "*    prepare api    *"
        echo "*********************"
        cat << EOF > /etc/icinga2/conf.d/api-users.conf
object ApiUser "root" {
    password = "${API_PASSWD}"
    permissions = [ "*" ]
}
EOF
	    icinga2 api setup
	fi

	tail -f /var/log/exim4/mainlog &

    for VAR in `env | sed 's/=.*//'`
    do
	    sed -i "s|__${VAR}__|${!VAR}|" /etc/icinga2/features-enabled/ido-mysql.conf;
    done
    
    echo "************************"
    echo "*    running daemon    *"
    echo "************************"
 	icinga2 daemon
fi
