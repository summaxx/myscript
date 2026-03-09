#!/bin/bash

#install gost
cat>/opt/gost.json<<EOF
{
  "services": [
    {
      "name": "service-0",
      "addr": ":3000",
      "interface": "10.1.0.4",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-1",
      "addr": ":3001",
      "interface": "10.1.0.5",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-2",
      "addr": ":3002",
      "interface": "10.1.0.6",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-3",
      "addr": ":3003",
      "interface": "10.1.0.7",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-4",
      "addr": ":3004",
      "interface": "10.1.0.8",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-5",
      "addr": ":3005",
      "interface": "10.1.0.9",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-6",
      "addr": ":3006",
      "interface": "10.1.0.10",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-7",
      "addr": ":3007",
      "interface": "10.1.0.11",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-8",
      "addr": ":3008",
      "interface": "10.1.0.12",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-9",
      "addr": ":3009",
      "interface": "10.1.0.13",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-10",
      "addr": ":3010",
      "interface": "10.1.0.14",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-11",
      "addr": ":3011",
      "interface": "10.1.0.15",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-12",
      "addr": ":3012",
      "interface": "10.1.0.16",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-13",
      "addr": ":3013",
      "interface": "10.1.0.17",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-14",
      "addr": ":3014",
      "interface": "10.1.0.18",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-15",
      "addr": ":3015",
      "interface": "10.1.0.19",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-16",
      "addr": ":3016",
      "interface": "10.1.0.20",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-17",
      "addr": ":3017",
      "interface": "10.1.0.21",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-18",
      "addr": ":3018",
      "interface": "10.1.0.22",
      "handler": {
        "type": "socks5"
      }
    },
	{
      "name": "service-19",
      "addr": ":3019",
      "interface": "10.1.0.23",
      "handler": {
        "type": "socks5"
      }
    },
  ]
}
EOF

wget https://github.com/go-gost/gost/releases/download/v3.0.0-nightly.20250207/gost_3.0.0-nightly.20250207_linux_amd64.tar.gz -O gost.tar.gz
tar -vxf gost.tar.gz
mv gost /usr/bin/
cat>/usr/lib/systemd/system/gost.service<<EOF
[Unit]
Description=gost
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=always
RestartSec=5
DynamicUser=true
ExecStart=/usr/bin/gost -C /opt/gost.json

[Install]
WantedBy=multi-user.target
EOF

systemctl enable gost.service

#config iptables
iptables -F
iptables -I INPUT -p tcp --dport 3000:3010 -j DROP
iptables-save > /opt/iptables.save

cat>/etc/network/if-pre-up.d/iptables<<EOF
#!/bin/bash
iptables-restore < /opt/iptables.save
EOF
chmod +x /etc/network/if-pre-up.d/iptables

#config network
cat>>/etc/network/interfaces<<EOF
auto eth0:1 eth0:2 eth0:3 eth0:4 eth0:5 eth0:6 eth0:7 eth0:8 eth0:9 eth0:10 eth0:11 eth0:12 eth0:13 eth0:14 eth0:15 eth0:16 eth0:17 eth0:18 eth0:19
iface eth0:1 inet static
address 10.1.0.5
netmask 255.255.255.0
iface eth0:2 inet static
address 10.1.0.6
netmask 255.255.255.0
iface eth0:3 inet static
address 10.1.0.7
netmask 255.255.255.0
iface eth0:4 inet static
address 10.1.0.8
netmask 255.255.255.0
iface eth0:5 inet static
address 10.1.0.9
netmask 255.255.255.0
iface eth0:6 inet static
address 10.1.0.10
netmask 255.255.255.0
iface eth0:7 inet static
address 10.1.0.11
netmask 255.255.255.0
iface eth0:8 inet static
address 10.1.0.12
netmask 255.255.255.0
iface eth0:9 inet static
address 10.1.0.13
netmask 255.255.255.0
iface eth0:10 inet static
address 10.1.0.14
netmask 255.255.255.0
iface eth0:11 inet static
address 10.1.0.15
netmask 255.255.255.0
iface eth0:12 inet static
address 10.1.0.16
netmask 255.255.255.0
iface eth0:13 inet static
address 10.1.0.17
netmask 255.255.255.0
iface eth0:14 inet static
address 10.1.0.18
netmask 255.255.255.0
iface eth0:15 inet static
address 10.1.0.19
netmask 255.255.255.0
iface eth0:16 inet static
address 10.1.0.20
netmask 255.255.255.0
iface eth0:17 inet static
address 10.1.0.21
netmask 255.255.255.0
iface eth0:18 inet static
address 10.1.0.22
netmask 255.255.255.0
iface eth0:19 inet static
address 10.1.0.23
netmask 255.255.255.0
EOF

#iptables check
cat>/usr/bin/ipc<<EOF
#!/bin/bash
iptables -F
iptables -I INPUT -p tcp --dport 3000:3010 -j DROP

cmd=$(echo $@ | sed -e 's/-A/-C/g;s/-I/-C/g')
${cmd} >/dev/null 2>&1
if [ $? -gt 0 ]; then
    cc=$@
    ${cc}
fi

iptables-save > /opt/iptables.save
EOF
chmod +x /usr/bin/ipc
reboot
