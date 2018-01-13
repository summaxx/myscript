#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

yum -y install epel-release
yum -y install wget git screen net-tools
yum -y install tigervnc
yum -y install tigervnc-server
yum -y groupinstall xfce

if [ `expr $version \> 7` -eq 0 ];then
	yum groupinstall "Chinese support"
	chkconfig vncserver on
else
    cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
	systemctl daemon-reload
	systemctl enable vncserver@:1.service
    yum -y install cjkuni-ukai-fonts
	cd /usr/share/fonts/chinese/
	mkfontscale
	mkfontdir
	fc-cache -fv
fi

yum -y install firefox

wget https://fpdownload.adobe.com/pub/flashplayer/pdc/28.0.0.126/flash-player-ppapi-28.0.0.126-release.x86_64.rpm
rpm -ivh flash-player-ppapi-28.0.0.126-release.x86_64.rpm


firewall_set(){
    echo -e "[${green}Info${plain}] firewall set start..."
    if [ `expr $version \> 7` -eq 0 ];then
        /etc/init.d/iptables status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            iptables -L -n | grep -i 5901 > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 5901 -j ACCEPT
                iptables -I INPUT -m state --state NEW -m udp -p udp --dport 5901 -j ACCEPT
                /etc/init.d/iptables save
                /etc/init.d/iptables restart
            else
                echo -e "[${green}Info${plain}] port 5901 has been set up."
            fi
        else
            echo -e "[${yellow}Warning${plain}] iptables looks like shutdown or not installed, please manually set it if necessary."
        fi
    else
        systemctl status firewalld > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            firewall-cmd --permanent --zone=public --add-port=5901/tcp
            firewall-cmd --permanent --zone=public --add-port=5901/udp
            firewall-cmd --reload
        else
            echo -e "[${yellow}Warning${plain}] firewalld looks like not running or not installed, please enable port 5901 manually if necessary."
        fi
    fi
    echo -e "[${green}Info${plain}] firewall set completed..."
}

firewall_set


