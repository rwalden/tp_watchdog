#!/bin/bash

GN='\033[0;32m'
RD='\033[0;31m'
LG='\033[1;36m'
BL='\033[0;34m'
NC='\033[0m'
PASSWD=V1s0r
clear
mysql -uroot -p$PASSWD visor -se "select ip_address from terminal where ip_address between '172.16.100.21' and '172.16.100.29'" > /tmp/terminal.log

for i in $(cat /tmp/terminal.log); do

ping -q -c 1 $i &> /dev/null

        if [ $? -eq 0 ]; then
        echo ""
        echo -e ${GN}========================================================${NC}
        echo -e ${GN}STARTING TIMER PANEL REDX REMOVAL $i${NC}
        echo "..........."
        echo -e ${LG}CHECKING HOSTNAME FOR $i .....WAIT${NC}

        HOSTNAME=`sshpass -p$PASSWD ssh -q $i hostname`

                if [ "VisorPitBull" == "$HOSTNAME" ]; then

                	echo -e ${RD}$i .....$HOSTNAME${NC}
                	echo -e ${LG}CHECKING HOSTNAME FOR $i .....DONE${NC}
                	echo "..........."
			echo -e ${LG}REMOVING FILES....WAIT${NC}
			sshpass -pPASSWD ssh -q $i << EOF
			rm -rf /usr/._.DS_Store
			rm -rf /usr/local/bin/._.DS_Store
			rm -rf /usr/local/._.DS_Store
			rm -rf /etc/systemd/system/visor_condog_check_connection.service
			rm -rf /usr/local/bin/check_connection.sh.
			rm -rf /usr/.DS_Store
			rm -rf /usr/local/bin/.DS_Store
			rm -rf /usr/local/.DS_Store
			rm -rf /tp-redx-install.sh
			rm -rf /etc/logrotate.d/condog
			rm -rf /usr/local/bin/disconnect_log.sh
			rm -rf /etc/._logrotate.d
			rm -rf /etc/logrotate.d/._condog
			rm -rf /root/._recoveryscreen.dat
			rm -rf /usr/local/bin/._reset_usb.py
			rm -rf /root/recoveryscreen.dat
			rm -rf /usr/local/bin/reset_usb.py
			rm -rf /usr/local/bin/zabbix_check_connection.sh
EOF
			echo -e ${LG}REMOVING FILES....DONE${NC}

                	echo "..........."
			echo -e ${LG}REMOVING SYSTEMCTL SERVICE FOR CONDOG SCRIPT.....WAIT${NC}
			condog_service () {
	        	sshpass -p$PASSWD ssh -q root@$i "systemctl disable visor_condog_check_connection.service && systemctl stop visor_condog_check_connection.service"
			}
			condog_service &> /dev/null
			echo -e ${LG}REMOVING SYSTEMCTL SERVICE FOR CONDOG SCRIPT.....DONE${NC}

                else

                	echo -e ${RD}CHECKING HOSTNAME FOR $i .....FAILED${NC}
                	echo -e ${RD}HOSTNAME DID NOT MATCHED THE REQUIRED VALUE${NC}
                	echo -e ${GN}========================================================${NC}

                fi
        else
                echo -e ${GN}========================================================${NC}
                echo -e ${GN}STARTING TIMER PANEL REDX UPDATE $i${NC}
                echo -e ${RD}$i IS UNREACHABLE${NC}
                echo -e ${GN}========================================================${NC}
        fi
done
		



		

