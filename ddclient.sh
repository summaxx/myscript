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
read -p "(Location cn y or n):" cn

if [ -f "/etc/redhat-release" ];then
	yum install perl-IO-Socket-SSL -y
	yum install wget -y
else
	apt-get install	perl-IO-Socket-SSL -y
fi
if [ "${cn}" == "y" ]; then
    wget -N --no-check-certificate http://47.102.199.72/chfs/shared/ddclient-3.8.3.tar.gz
else
	wget -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/ddclient-3.8.3.tar.gz
fi
tar -xvf ddclient-3.8.3.tar.gz
cd ddclient-3.8.3
cp ddclient /usr/sbin/
mkdir /etc/ddclient
mkdir /var/cache/ddclient
cp sample-etc_ddclient.conf /etc/ddclient/ddclient.conf
sed -i "s#daemon=300#daemon=60#" /etc/ddclient/ddclient.conf
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
   apt-get install libio-socket-ssl-perl -y
fi

service ddclient start
echo -e "\033[32mDone!\033[0m"