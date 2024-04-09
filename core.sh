#!/bin/bash

sudo kill -9 $(sudo ps aux | grep -v "grep" | grep "./ore.sh" | awk '{print $2}')
#sudo sed -i 's/10000/1000/g' /root/ore.sh
sudo sed -i 's/lt 5/lt 2/g' /root/ore.sh
sudo killall ore
#sudo -i
#cargo install ore-cli
#exit
sudo screen -S ore -X stuff './ore.sh^M'
sleep 3
ps a
