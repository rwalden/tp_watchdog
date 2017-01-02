#!/bin/bash
mkdir -p /var/log/zabbix_screen
timestamp=`date +"%m-%d-%y|%T"`
logfile=/var/log/condog
#logfile_z1=/var/log/zabbix_screen/rscreen
logfile_z2=/var/log/zabbix_screen/rscreen.$timestamp
#logfile=/dev/console
#logfile=`tty`
chmod -R a+rwx /var/log/zabbix_screen

dmesg -n 1
browser=/etc/xdg/lxsession/LXDE/autostart
test_url=http://172.16.100.20/pong.html

startup_delay_sec=15
wget_timeout=5
wget_tries=2
wget_force_timeout=11
tries_b4_reboot=8
tries_b4_adapter_reset=5
tries_b4_ifup=3
tries_b4_logging=1
reboot_count_b4_stop=5
sleep_b4_reboot=3600

check_for_usb_disconnect() {
	dmesg | grep "rtusb_disconnect" > /dev/null	
	disconnect=$?
	return $disconnect
	#consider checking /var/log/wpa_action.log
}

wifi_adaptor_present() {
	lsusb | grep Ralink > /dev/null	
	return $?
	
}


restart_network() {
	echo "restart interface" >> $logfile
	echo "ifdown" >> $logfile
	timeout 10 /sbin/ifdown ra0	
	sleep 5
	echo "ifup" >> $logfile
	timeout 20 /sbin/ifup ra0	
	sleep 10
	echo "done" >> $logfile
	echo "Action: Network Restart (ifdown ra0 , ifup ra0)" >> $logfile_z2
}

reset_network_adaptor() {
	echo "hard reset interface" >> $logfile
	echo "ifdown" >> $logfile
	timeout 10 /sbin/ifdown ra0	
	sleep 2
	echo "starting reset" >> $logfile
	/usr/local/bin/reset_usb.py Ralink >> $logfile
	echo "reset initiated" >> $logfile
	sleep 25
	echo "ifup" >> $logfile
	timeout 20 /sbin/ifup ra0	
	sleep 10
	echo "done" >> $logfile
	echo "Action: HW Interface Restart (fcntl.ioctl(f, USBDEVFS_RESET, 0))" >> $logfile_z2
}

reboot_panel() {
	#systemctl reboot
	# a nice reboot rarely works, so do the impolite thing...
	echo "rebooting system..." >> $logfile
	sync
	echo b > /proc/sysrq-trigger
}

open_watchdog() {
	exec 5> /dev/watchdog
}
close_watchdog() {
	exec 5>&-
}
reset_watchdog() {
	echo \n >&5
}

echo $logfile
# force a reboot on kernel panic
echo 5 > /proc/sys/kernel/panic

#wait to be sure system initialization is complete
sleep $startup_delay_sec
echo "======= Check connection log started $(date) =========" >> $logfile

connected=1
disconnect_count=0
tried_down_up=0

open_watchdog

while :
do

reset_watchdog

echo -n "<" >> $logfile
#check if 172.16.100.20 is accessible 
timeout $wget_force_timeout wget --timeout=$wget_timeout --tries=$wget_tries -O /dev/null --spider $test_url 2>&1 | grep -F connected > /dev/null 2>&1
success=$?
echo -n ">" >> $logfile
if [ $success -eq 0 ]; then
	# connection check successful
	disconnect_count=0
	tried_down_up=0
	if [ $connected -eq 1 ]
	then
		echo -n "." >> $logfile
		sleep 2
	else
		echo "Reconnected!" >> $logfile
		connected=1
		/etc/init.d/lightdm restart
		sleep 2
	fi
else
	# failed to get file
	if [ $connected -eq 0 ]
	then
		# still disconnected, count up to an intervention
		((disconnect_count++))
		echo -n "!$disconnect_count" >> $logfile
		if [ $disconnect_count -gt $tries_b4_reboot ]
		then

		    # Reboot max count per 1hour interval is 5x
		    COUNT=`ls /var/log/zabbix_screen/* | wc | awk {'print $1'}`
		    if (( $COUNT % 5 == 0 ))
		    then
	               echo "Reboot Count reached tries. Service will wait for 1 hour to resume network rescue."
		       sleep $sleep_b4_reboot
                       reboot_panel
		    else
		       echo "Rebooting system...." >> $logfile
		       echo -e "`date`\n$(cat $logfile_z1)" > $logfile_z2
		       #mv $logfile_z1 $logfile_z2
		       
		       reboot_panel			
		       exit
                    fi
		elif [ $disconnect_count -gt $tries_b4_adapter_reset ]
		then
                    #disconnect_count=0
		    reset_network_adaptor			
		elif [ $disconnect_count -gt $tries_b4_ifup ] 
                then
		    restart_network
		elif [ $disconnect_count -eq $tries_b4_logging ] 
                then
		    sh /usr/local/bin/disconnect_log.sh
                fi
	else
		echo "Disconnected." >> $logfile
		cat /root/recoveryscreen.dat > /dev/fb0
		connected=0
	fi
fi
done

close_watchdog
