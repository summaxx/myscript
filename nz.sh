#!/bin/bash
cd
sudo cp nezha-agent.service /etc/systemd/system/nezha-agent.service
sudo chmod +x /etc/systemd/system/nezha-agent.service
sudo systemctl restart nezha-agent.service
echo "nezha ok"
