#!/bin/bash
#Generate DHCP records, and puppet foreman-hammer-cli records for a supermicro bladesystem enclosure

if [ -z "$1" ]
  then
    echo "Please supply a blade enclosure as an argument. Ex: ./bladerunner.sh tb21"
    exit 1
fi
MCNUM=$1
MCIP=$(host ${MCNUM}mc | awk '{print $4}');
#HOSTS=$(for i in `seq -w 20`; do echo $mcnum$i;done)
#IPS=$(for host in $hosts; do host $host|awk '{print $4}';done)
#exec > >(tee $MCNUM.txt)

cd `dirname "$0"`
echo "OKAY I'M RUNNING NOW, USUALLY TAKES ABOUT 30 SECONDS FOR 20 BLADES"
for bn in `seq -w 20`;
do
        echo -n "$MCNUM$bn ">>$MCNUM.txt; java -jar ./SMCIPMITool.jar $MCIP ADMIN ADMIN blade $bn config | grep -a "LAN 1 MAC" | awk '{print $5}' >> $MCNUM.txt;
done

for hosts in $(awk '{print$1}' $MCNUM.txt);
do
    MACS=$(grep -w $hosts $MCNUM.txt|awk '{print$NF}');echo -ne "host $hosts.companyname.com {hardware ethernet $MACS; fixed-address $hosts.companyname.com; }\n" >> $MCNUM.dhcp.txt;
done

echo "Outputted files $MCNUM.txt and $MCNUM.dhcp.txt"
