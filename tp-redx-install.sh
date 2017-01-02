#!/bin/bash
GN='\033[0;32m'
RD='\033[0;31m'
LG='\033[1;36m'
BL='\033[0;34m'
NC='\033[0m'
clear
mysql -uroot -pV1s0r visor -se "select ip_address from terminal where ip_address between '172.16.100.21' and '172.16.100.29'" > /tmp/terminal.log

for i in $(cat /tmp/terminal.log); do

ping -q -c 1 $i &> /dev/null

        if [ $? -eq 0 ]; then
        echo ""
        echo -e ${GN}========================================================${NC}
        echo -e ${GN}STARTING TIMER PANEL REDX UPDATE $i${NC}
        echo "..........."
        echo -e ${LG}CHECKING HOSTNAME FOR $i .....WAIT${NC}

        HOSTNAME=`sshpass -pV1s0r ssh -q $i hostname`

                if [ "VisorPitBull" == "$HOSTNAME" ]; then

                	echo -e ${RD}$i .....$HOSTNAME${NC}
                	echo -e ${LG}CHECKING HOSTNAME FOR $i .....DONE${NC}
                	echo "..........."
			echo -e ${LG}COPYING FILES....WAIT${NC}
			sshpass -pV1s0r scp -r -q /usr/local/src/timerpanel/tp_watchdog/* $i:/ &> /dev/null
			echo -e ${LG}COPYING FILES....DONE${NC}

                	echo "..........."
			echo -e ${LG}SETTING UP WIFI CHANGES.....WAIT${NC}
			wifi () {
			sshpass -pV1s0r ssh -q 172.16.100.3 /interface wireless set band=5ghz-a rate-set=configured supported-rates-a/g=6Mbps channel-width=20mhz number=0
			}
			wifi &> /dev/null
			echo -e ${LG}SETTING UP WIFI CHANGES.....DONE${NC}

			echo "..........."
			echo -e ${LG}SETTING UP SYSTEMCTL SERVICE FOR CONDOG SCRIPT.....WAIT${NC}
			condog_service () {
			sshpass -pV1s0r ssh -q root@$i chmod 777 /usr/local/bin/check_connection.sh
			sshpass -pV1s0r ssh -q root@$i chmod 777 /usr/local/bin/zabbix_check_connection.sh 
	        	#sshpass -pV1s0r ssh -q root@$i "systemctl enable visor_condog_check_connection.service && systemctl start visor_condog_check_connection.service"
			}
			condog_service &> /dev/null
			echo -e ${LG}SETTING UP SYSTEMCTL SERVICE FOR CONDOG SCRIPT.....DONE${NC}

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
		



		

