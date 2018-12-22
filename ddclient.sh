#!/bin/bash
#
##########################################
#
#  ddclient install for namecheap
#  author: summax
#    date: 2018-11-26
#
#   debug: /usr/sbin/ddclient -daemon=0 -debug -verbose -noquiet
##########################################

#8879242fb0be49fb91821071ed9cad55
stty erase '^H'

read -p "(Dns Domain):" domain
read -p "(Login Domain):" login
read -p "(Login Passwd):" passwd

if [ -f "/etc/redhat-release" ];then
	yum install perl-IO-Socket-SSL -y
	yum install wget -y
else
	apt-get install	perl-IO-Socket-SSL -y
fi

wget https://github.com/summaxx/myscript/raw/master/ddclient-3.9.0.tar.gz
tar -xvf ddclient-3.9.0.tar.gz
cd ddclient-3.9.0
cp ddclient /usr/sbin/
mkdir /etc/ddclient
mkdir /var/cache/ddclient
cp sample-etc_ddclient.conf /etc/ddclient/ddclient.conf
sed -i "s#daemon=300#daemon=120#" /etc/ddclient/ddclient.conf
echo -e "use=web, web=dynamicdns.park-your-domain.com/getip
protocol=namecheap 
server=dynamicdns.park-your-domain.com 
login=$login
password=$passwd
$domain" >> /etc/ddclient/ddclient.conf

if [ -f "/etc/redhat-release" ];then
   cp sample-etc_rc.d_init.d_ddclient /etc/rc.d/init.d/ddclient
   /sbin/chkconfig --add ddclient
else
   cp sample-etc_rc.d_init.d_ddclient.ubuntu /etc/init.d/ddclient
   update-rc.d ddclient defaults
fi

service ddclient start
echo -e "\033[32mDone!\033[0m"