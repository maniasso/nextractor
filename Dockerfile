#!/usr/bin/docker build .
#
# VERSION               1.0

FROM       alpine:latest
MAINTAINER robfm@kyndryl.com

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk update && apk add \
    bash \
    wget \
    supervisor \
    rsyslog \
    busybox-suid \
    bind-tools \
    openssh-client \
    nmap \
    busybox-extras \
    curl \
    python3 \
    py3-pip

# perl-font-ttf fron testing repo (needed for PDF reports)
RUN pip install influxdb \
    pip install requests

RUN mkdir -p /home/nextractor


#COPY configs/crontab /var/spool/cron/crontabs/root
RUN chmod 640 /var/spool/cron/crontabs/root && chown root.cron /var/spool/cron/crontabs/root && \
    echo "0,10,20,30,40,50 * * * * /home/nextractor/nextract_server.py 1>/tmp/nextract_server.log 2>/tmp/nextract_server.err" >> /var/spool/cron/crontabs/root


# extract tarballs
WORKDIR /home/nextractor
RUN wget https://www.ibm.com/support/pages/system/files/inline-files/nextract_plus35.zip
RUN cd /home/nextractor && \
    unzip nextract_plus35.zip 
    
COPY supervisord.conf /etc/
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

VOLUME [ "/home/nextractor" ]

ENTRYPOINT [ "/startup.sh" ]
