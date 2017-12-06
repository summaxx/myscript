#!/bin/sh
#description: installing pure-ftpd-1.0.36 package
#             and setting some items of configure file
#author: i@xuzeshui.com
#date: 2014-04-23
#
yum groupinstall "Development Tools" -y
cd /usr/local/src
wget -N --no-check-certificate https://download.pureftpd.org/pub/pure-ftpd/releases/obsolete/pure-ftpd-1.0.36.tar.gz
tar -xvf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pure-ftpd-1.0.36 --with-virtualchroot  --with-everything --with-puredb
make 
make install
mkdir -p /usr/local/pure-ftpd-1.0.36/etc/
cp ./configuration-file/pure-ftpd.conf /usr/local/pure-ftpd-1.0.36/etc/
cp ./configuration-file/pure-config.pl /usr/local/pure-ftpd-1.0.36/bin/
chmod a+x /usr/local/pure-ftpd-1.0.36/bin/pure-config.pl

cd /usr/local/
ln -s pure-ftpd-1.0.36 pure-ftpd


/usr/local/pure-ftpd-1.0.36/bin/pure-config.pl /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
echo "/usr/local/pure-ftpd-1.0.36/bin/pure-config.pl /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf" >> /etc/rc.d/rc.local

sed -i 's#MinUID                      100#MinUID                      98#g' /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/MaxClientsNumber            50/MaxClientsNumber            1000/g' /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/# TrustedGID                    100/TrustedGID                    99/g' /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/MaxClientsPerIP             8/MaxClientsPerIP             200/g'  /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/AllowUserFXP                no/AllowUserFXP                yes/g'  /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/MaxDiskUsage               99/MaxDiskUsage               97/g'  /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -i 's/# PassivePortRange          30000 50000/PassivePortRange          30000 31000/g'  /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf
sed -ir '/\/etc\/pureftpd.pdb/a\PureDB                        /usr/local/pure-ftpd/etc/pureftpd.pdb' /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf

mkdir /home/haossftp
chown nobody:nobody /home/haossftp
chmod 755 /home/haossftp
echo "\r\n\033[1;0;31mplease set user passwd\033[0m"
cd /usr/local/pure-ftpd/bin
/pure-pw useradd ssr -u99 -g99 -d /home/haossftp
/pure-pw mkdb
cd

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 30000:31000 -j ACCEPT
service iptables save

echo '#!/bin/bash' > /etc/init.d/ss
echo '# chkconfig: 2345 55 25' >> /etc/init.d/ss
echo '# Description: run ftp' >> /etc/init.d/ss

echo '/usr/local/pure-ftpd-1.0.36/bin/pure-config.pl /usr/local/pure-ftpd-1.0.36/etc/pure-ftpd.conf' >> /etc/init.d/ftpd
chkconfig --add ftpd
chkconfig ftpd on
echo "\r\n\033[1;0;32mInstallation is complete!\033[0m\r\n user:\033[1;0;31mssr\033[0m"

#使用ftp 
#       安装后创建用户，比如创建blog这个用户登陆ftp，则进入安装目录的bin下使用 pure-pwd这个工具，具体参数可以看帮助。
#./pure-pw useradd blog -u99 -g99 -d /data/vhosts/blog.xuzeshui.com
#       上述命令创建了一个ftp用户名为blog，-u -g分别设置用户的归属，由于配置的时候配置到nobody:nobody，所以为99, -d为用户所在的主目录，同时注意该目录也要有有权限。
#       更改配置和修改用户后，请一定使用 pure-pw mkdb 提交更改，否则是不会生效的。