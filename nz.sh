#!/bin/bash
sudo cp /home/user/nezha-agent.service /etc/systemd/system/nezha-agent.service
sudo chmod +x /etc/systemd/system/nezha-agent.service
sudo systemctl daemon-reload
sudo systemctl restart nezha-agent.service
echo "nezha ok"
