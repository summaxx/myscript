#!/bin/bash

sudo kill -9 $(sudo ps aux | grep -v "grep" | grep "./ore.sh" | awk '{print $2}')
sudo sed -i 's/10000/1000/g' /root/ore.sh
sudo killall ore
sudo screen -S ore -X stuff './ore.sh^M'
