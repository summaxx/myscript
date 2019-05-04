#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: socks5
#	Version: 1.0.1
#	Author: timmax
#	email: timmax110@163.com
#=================================================

sh_ver="1.0.1"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

echo Info "Environmental installation"
if [ -f "/etc/redhat-release" ];then
	yum -y install gcc automake make net-tools
	yum -y install pam-devel openldap-devel cyrus-sasl-devel openssl-devel
else
    apt-get install -y build-essential libssl-dev zlib1g-dev git net-tools 
	apt-get install -y gcc g++ libtool automake
	apt-get install -y libsasl2-dev libldap2-dev libssl-dev
	apt-get install -y libpam0g-dev	
fi
echo Info "socks5 install"
wget https://github.com/summaxx/myscript/raw/master/ss5-3.8.9-8.tar.gz
tar xvf ss5-3.8.9-8.tar.gz
cd ss5-3.8.9
./configure && make && make install
chmod +x /etc/init.d/ss5
echo "SS5_OPTS=\" -u root -b 0.0.0.0:80\"" >>/etc/sysconfig/ss5
echo "haoss abc321" >> /etc/opt/ss5/ss5.passwd
sed -i "87c auth    0.0.0.0/0               -               u" /etc/opt/ss5/ss5.conf
sed -i "s/^#\(permit\)/\1/" /etc/opt/ss5/ss5.conf
service ss5 start
echo -e "${Green_font_prefix}Port:${Font_color_suffix} ${Red_font_prefix}80${Font_color_suffix}"
echo -e "${Green_font_prefix}User:${Font_color_suffix} ${Red_font_prefix}haoss${Font_color_suffix}"
echo -e "${Green_font_prefix}Pass:${Font_color_suffix} ${Red_font_prefix}abc321${Font_color_suffix}"
echo Info "Do!"