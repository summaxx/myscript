#!/bin/bash

apt update
apt install lrzsz net-tools unzip -y
mkdir bot
cd bot
wget https://github.com/summaxx/myscript/raw/refs/heads/master/50-cloud-init.yaml
mv 50-cloud-init.yaml /etc/netplan/
wget https://sourceforge.net/projects/rust-mev-bot/files/rust-mev-bot-1.0.10.zip
unzip rust-mev-bot-1.0.10.zip
chmod +x upgrade.sh
./upgrade.sh
chmod +x run.sh
cat>/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg<<EOF
network: {config: disabled}
EOF
echo "Do!"
