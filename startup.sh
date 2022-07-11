#!/bin/bash

if [ -f /firstrun ]; then
        # remote syslog server to docker host
        SYSLOG=`netstat -rn|grep ^0.0.0.0|awk '{print $2}'`
        echo "*.* @$SYSLOG" >> /etc/rsyslog.conf

        # Start syslog server to see something
        # /usr/sbin/rsyslogd

        echo "Running for first time.. need to configure..."

        # Generate Host keys
        ssh-keygen -A

        if [[ -z "${TIMEZONE}" ]]; then
                # set default TZ to London, enable TZ change via GUI
                TIMEZONE="Europe/London"
        fi
        echo "${TIMEZONE}" > /etc/timezone
        chmod 666 /etc/timezone
        ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime


        # initialize lpar2rrd's crontab
        crontab -u root /var/spool/cron/crontabs/root
        wget https://www.ibm.com/support/pages/system/files/inline-files/nextract_plus35.zip
        cd /home/nextractor && unzip nextract_plus35.zip
         
        cd /home/nextractor
        for i in `ls /home/nextractor/*.conf | grep -v example`
        do 
        echo "30 * * * * /home/nextractor/nextract_plus.py $i" >> /var/spool/cron/crontabs/root
        done
        
        # clean up
        rm /firstrun
fi

# Sometimes with un unclean exit the rsyslog pid doesn't get removed and refuses to start
if [ -f /var/run/rsyslogd.pid ]; then
        rm /var/run/rsyslogd.pid
fi

# Start supervisor to start the services
/usr/bin/supervisord -c /etc/supervisord.conf -l /var/log/supervisor.log -j /var/run/supervisord.pid
