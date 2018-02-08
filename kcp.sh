#! /bin/bash

yum install wget -y
wget https://github.com/xtaci/kcptun/releases/download/v20171201/kcptun-linux-amd64-20171201.tar.gz
mkdir kcptun
tar -xvzf kcptun-linux-amd64-20171201.tar.gz -C kcptun
cd kcptun
wget https://raw.githubusercontent.com/summaxx/myscript/master/server-config.json
wget -P /etc/init.d/ https://raw.githubusercontent.com/summaxx/myscript/master/kcptun.sh
chmod +x /etc/init.d/kcptun.sh
chkconfig --add kcptun
chkconfig kcptun on
service kcptun start
echo "kcptun start!"


