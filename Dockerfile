FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

ADD icinga.key /tmp/icinga.key

RUN apt-key add /tmp/icinga.key; \
    echo 'deb http://packages.icinga.com/debian icinga-buster main' > /etc/apt/sources.list.d/icinga.list; \
    apt-get update -y; \
    apt install icinga2 monitoring-plugins-standard -y

# create /run/icinga2 for pid files
RUN mkdir -p /run/icinga2

RUN icinga2 feature disable mainlog

RUN apt install -y exim4-daemon-heavy

RUN apt-get install -y icinga2-ido-mysql
ADD graphite.conf /etc/icinga2/features-available/graphite.conf
ADD ido-mysql.conf /etc/icinga2/features-enabled/ido-mysql.conf

ADD update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf
ADD start.sh /opt/start.sh
RUN chmod +x /opt/start.sh
RUN mkdir -p /run/icinga2; \
    touch /run/icinga2/icinga2.pid; \
    chown nagios /run/icinga2/icinga2.pid

VOLUME ["/etc/icinga2/conf.d"]

EXPOSE 5665

ENTRYPOINT ["/opt/start.sh"]
CMD ["normal"]
