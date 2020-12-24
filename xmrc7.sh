#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sudo yum install -y epel-release
sudo yum install -y git make cmake gcc gcc-c++ libstdc++-static libuv-static hwloc-devel openssl-devel
sudo yum install screen -y
git clone https://github.com/xmrig/xmrig.git
sed -i "s/kDefaultDonateLevel = 1/kDefaultDonateLevel = 0/g" xmrig/src/donate.h
sed -i "s/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/g" xmrig/src/donate.h
mkdir xmrig/build && cd xmrig/build
cmake ..
make -j$(nproc)
screen -S x
./xmrig -o xmr.f2pool.com:13531 -u 84W6ZSyJ7GW1MJrrLJpdYd1tbEfgTzjsP1XHjS4r6CyKeMFbxHRN2GrZLu4NaoVkF6QdgFNuu8RFA4yNmzhP1Vv44qrpQMm.Lin01 -k