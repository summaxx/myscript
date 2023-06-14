#!/bin/bash

function Install_Gost(){
  Installation_dependency
  wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-armv7-2.11.5.gz
  gunzip https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-armv7-2.11.5.gz
  mv gost-linux-armv7-2.11.5 /usr/bin/gost
  chmod -R 777 /usr/bin/gost
  wget --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
  mkdir /etc/gost && wget --no-check-certificate https://github.com/summaxx/myscript/raw/master/gostc.json && mv gostc.json /etc/gost/config.json && chmod -R 777 /etc/gost
  systemctl enable gost && systemctl restart gost
}


function Installation_dependency() {
  apt-get update -y
  gzip_ver=$(gzip -V)
  if [[ -z ${gzip_ver} ]]; then
    if [[ ${release} == "centos" ]]; then
      yum update
      yum install -y gzip wget
    else
      apt-get update
      apt-get install -y gzip wget
    fi
  fi
  apt-get install hwloc nodejs -y
}

function Install_XMRIG(){
  wget --no-check-certificate https://github.com/summaxx/myscript/raw/master/xmrig-arm
  chmod 755 xmrig-arm
  mv xmrig /usr/bin/xmrig-arm
  chmod -R 777 /usr/bin/xmrig-arm
  wget  --no-check-certificate https://github.com/summaxx/myscript/raw/master/xmgarm.service
  chmod 755 xmgarm.service
  mv xmgarm.service /usr/lib/systemd/system
  systemctl enable xmgarm && systemctl restart xmgarm
}

sleep 3s
Installation_dependency
Install_Gost
Install_XMRIG