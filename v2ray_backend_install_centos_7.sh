#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cat << "EOF"
 _      __     ______   _      __  
| | /| / /__ _/ / / /  (_)__  / /__
| |/ |/ / _ `/ / / /__/ / _ \/  '_/
|__/|__/\_,_/_/_/____/_/_//_/_/\_\ 
Author: YihanH
Github: https://github.com/YihanH/v2ray-backend-server-install-scripts
EOF
echo "V2Ray proxy node installation script for CentOS 7 x64"
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
echo "Press Y for continue the installation process, or press any key else to exit."
read is_install
if [[ is_install =~ ^[Y,y,Yes,YES]$ ]]
then
	echo "Bye"
	exit 0
fi
echo "Updatin exsit package..."
yum clean all && rm -rf /var/cache/yum && yum update -y
echo "Install necessary package..."
yum install epel-release -y && yum makecache
yum install screen net-tools htop ntp -y
echo "Disabling firewalld..."
systemctl stop firewalld && systemctl disable firewalld
echo "Setting system timezone..."
timedatectl set-timezone Asia/Taipei && systemctl stop ntpd.service && ntpdate us.pool.ntp.org
echo "Downloading bin file..."
mkdir -p /soft/v2ray && cd /soft/v2ray
wget -O v2ray-agent https://docs.walllink.io/bin && chmod +x v2ray-agent
echo "Downloading config file..."
wget  https://raw.githubusercontent.com/YihanH/v2ray-backend-server-install-scripts/master/agent.yaml
echo -n "Please enter DB username:"
read db_user
echo -n "DB password:"
read db_password
echo -n "Server node ID:"
read node_id
echo "Writting config..."
sed -i -e "s/nodeId: xxxx/nodeId: ${node_id}/g" -e "s/user: xxxx/user: ${db_user}/g" -e "s/pass: xxxx/pass: ${db_password}/g" agent.yaml

cat >> /etc/security/limits.conf << EOF
* soft nofile 51200
* hard nofile 51200
EOF
ulimit -n 51200
echo "System require a reboot to complete the installation process, press Y to continue, or press any key else to exit this script."
read is_reboot
if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
    reboot
else
    echo -e "${green}Info:${plain} Reboot has been canceled..."
    exit 0
fi