#!/bin/bash

chatscript="
ABORT		BUSY
ABORT		VOICE
ABORT		\"NO CARRIER\"
ABORT		\"NO DIALTONE\"
ABORT		\"NO DIAL TONE\"
ABORT		\"NO ANSWER\"
ABORT		\"DELAYED\"
ABORT		\"ERROR\"
ABORT		\"+CGATT: 0\"
\"\"		AT
TIMEOUT		12
OK		ATH
OK		ATE1
OK		AT+CGDCONT=1,\"IP\",\"internet.iot\",\"\",0,0
OK		ATD*99#
TIMEOUT		22
CONNECT		\"\"
"

peers="
user \"myusername@realm\"
connect \"/usr/sbin/chat -v -f /etc/ppp/sim7000\"
/dev/ttyUSB3
115200
debug
nocrtscts
nodetach
ipcp-accept-local
ipcp-accept-remote
noipdefault
usepeerdns
defaultroute
persist
noauth
"

daemonfile="
[Unit]
Description=PPP SIM7000C dialing

[Service]
ExecStart=/usr/sbin/pppd call sim7000
KillMode=process
Restart=on-failure
Type=simple

[Install]
WantedBy=multi-user.target
Alias=sim7000.service
"

echo "$peers" | sudo tee /etc/ppp/peers/sim7000
echo "$chatscript" | sudo tee /etc/ppp/sim7000
echo "$daemonfile" | sudo tee /etc/systemd/system/sim7000.service

if [ "$(whereis pppd)" == "pppd:" ]; then
        sudo apt clean
        sudo apt update -y
        sudo apt update ppp
fi

sudo systemctl daemon-reload
sudo systemctl enable --now sim7000
sudo systemctl status sim7000
