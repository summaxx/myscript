#!/bin/sh

echo "" > /var/log/secure && service rsyslog restart
wget http://freefr.dl.sourceforge.net/project/denyhosts/denyhosts/2.6/DenyHosts-2.6.tar.gz
tar xvf DenyHosts-2.6.tar.gz
cd DenyHosts-2.6
python setup.py install
cd /usr/share/denyhosts/
cp denyhosts.cfg-dist denyhosts.cfg
cp daemon-control-dist daemon-control
sed -i "s#PURGE_DENY =#PURGE_DENY = 4w#" /usr/share/denyhosts/denyhosts.cfg
sed -i "s#DENY_THRESHOLD_INVALID = 5#DENY_THRESHOLD_INVALID = 3#" /usr/share/denyhosts/denyhosts.cfg
sed -i "s#DENY_THRESHOLD_VALID = 10#DENY_THRESHOLD_VALID = 3#" /usr/share/denyhosts/denyhosts.cfg
sed -i "s#DENY_THRESHOLD_ROOT = 1#DENY_THRESHOLD_ROOT = 3#" /usr/share/denyhosts/denyhosts.cfg
sed -i "s#HOSTNAME_LOOKUP=YES#HOSTNAME_LOOKUP=NO#" /usr/share/denyhosts/denyhosts.cfg

ln -sf /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
chkconfig --add denyhosts
chkconfig --level 2345 denyhosts on

/etc/init.d/denyhosts start
