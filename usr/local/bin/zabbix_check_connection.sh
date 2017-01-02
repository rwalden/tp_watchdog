#!/bin/bash
set -x
LOGFILE=/var/log/zabbix_screen
GETFILE=`ls -rt /var/log/zabbix_screen/ | grep -v total | grep -v archive | cut -d "/" -f5 | head -n1`
ARCHIVE=/var/log/zabbix_screen/archive
COUNT=`ls /var/log/zabbix_screen/ | grep -v archive | wc | awk {'print $1'}`
ZABBIX_SERVER=10.0.3.44

ping -q -c 2 $ZABBIX_SERVER &> /dev/null

if [ $? -eq 0 ]; then
                if [ "$COUNT" -gt "0" ]; then
			cat $LOGFILE/$GETFILE
	
			# Moving logfile to archive after zabbix-agent log
			mkdir -p $ARCHIVE
			mv $LOGFILE/$GETFILE $ARCHIVE
		else
			echo "No Logfile to Archive"
		fi

else
	echo "Unable to connect to zabbix-server.\n This will not process TP-RedScreen Condog Log"
fi
