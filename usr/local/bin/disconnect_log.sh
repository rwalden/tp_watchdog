#!/bin/sh

LOGNAME=/var/log/disconnect
#LOGNAME=`tty`

echo logging to $LOGNAME

CURDATE=`date`
echo "======== WIFI DISCONNECT LOG $CURDATE ======= " &>> $LOGNAME
dmesg > /tmp/dmesg-$CURDATE.log
echo "------- lsusb -------" &>> $LOGNAME
lsusb &>> $LOGNAME
echo "------- modules -------" &>> $LOGNAME
lsmod &>> $LOGNAME
echo "------- iwconfig -------" &>> $LOGNAME
iwconfig &>> $LOGNAME
echo "------- current ESSID  -------" &>> $LOGNAME
iwgetid &>> $LOGNAME
echo "------- iwlist frequency -------" &>> $LOGNAME
iwlist ra0 frequency | grep "Current" &>> $LOGNAME
echo "------- iwlist keys -------" &>> $LOGNAME
iwlist ra0 key | grep "Current" &>> $LOGNAME
echo "------- driver version -------" &>> $LOGNAME
iwpriv ra0 driverVer &>> $LOGNAME
echo "------- ping WAP ---------" &>> $LOGNAME
ping -w5 -c3 172.16.100.3 &>> $LOGNAME
echo "------- ping router ---------" &>> $LOGNAME
ping -w5 -c3 172.16.100.1 &>> $LOGNAME
echo "------- ping DNA ---------" &>> $LOGNAME
ping -w5 -c3 172.16.100.20 &>> $LOGNAME
echo "------- iwpriv stat -------" &>> $LOGNAME
iwpriv ra0 connStatus &>> $LOGNAME
iwpriv ra0 stat &>> $LOGNAME
iwpriv ra0 bainfo &>> $LOGNAME
echo "------- wifi site survey -------" &>> $LOGNAME
iwpriv ra0 set SiteSurvey=1 &>> $LOGNAME
iwpriv ra0 get_site_survey &>> $LOGNAME
echo "------- wifi scan -------" &>> $LOGNAME
iwlist ra0 ap &>> $LOGNAME
iwlist ra0 scanning  &>> $LOGNAME
echo "------- dmesg snapshot  -------" &>> $LOGNAME
dmesg &>> $LOGNAME
echo "======== END DISCONNECT LOG $CURDATE =======" &>> $LOGNAME
