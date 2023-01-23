#!/bin/bash

###### install node.js  
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && apt-get install -qq -y nodejs

###### install ironfish binary 
npm install -g ironfish
npm update -g ironfish

###### download ironfish chain snapshot
ironfish chain:download --confirm



##### Setup account
echo "Enter required variables and remember(!): "
read -p "Graffiti name:" IRONFISH_GRAFFITI_NAME
read -p "Node name: " IRONFISH_GRAFFITI_NAME

if [ ${SHELL} == "/usr/bin/zsh" ]; then
echo "export IRONFISH_GRAFFITI_NAME=${IRONFISH_GRAFFITI_NAME} >> $HOME/.zshrc"
echo "export IRONFISH_NODE_NAME=${IRONFISH_NODE_NAME} >> $HOME/.zshrc"
else
echo "export IRONFISH_GRAFFITI_NAME=${IRONFISH_GRAFFITI_NAME} >> $HOME/.bashrc"
echo "export IRONFISH_NODE_NAME=${IRONFISH_NODE_NAME} >> $HOME/.bashrc"
fi

ironfish wallet:create ${IRONFISH_GRAFFITI_NAME}
ironfish wallet:use ${IRONFISH_GRAFFITI_NAME}
ironfish config:set blockGraffiti ${IRONFISH_GRAFFITI_NAME}
ironfish config:set accountName ${IRONFISH_GRAFFITI_NAME}
ironfish config:set nodeName ${IRONFISH_NODE_NAME}
ironfish config:set blockGraffiti "${IRONFISH_GRAFFITI_NAME}"
ironfish config:set enableTelemetry "true"

mkdir -p ${HOME}/.ironfish/privkeys/
ironfish wallet:export ${HOME}/.ironfish/privkeys/${IRONFISH_GRAFFITI_NAME}_backup.json



##### Setup systemd service
echo "[Unit]
Description=Ironfish node
After=network-online.target

[Service]
User=root
ExecStart=$(which ironfish) start
Restart=always
RestartSec=5
LimitNOFILE=30000
OOMScoreAdjust=0

LimitAS=infinity
LimitCPU=infinity
LimitFSIZE=infinity
LimitAS=infinity
LimitNPROC=30000
LimitMEMLOCK=inifinity


CPUSchedulingPolicy=other
CPUSchedulingPriority=0
MemoryHigh=$(shuf -i 60-80 | head -1)%
Nice=-$(shuf -i 10-18 | head -1)
TasksMax=infinity
TasksAccounting=false

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/ironfishd.service

systemctl daemon-reload
systemctl enable ironfishd.service
systemctl restart ironfishd.service


#######
echo ""
echo "############# Information #############"
echo "Using ironfish account: $(ironfish wallet:which)"
echo "Wallet backup can be found in file: ${HOME}/.ironfish/privkeys/${IRONFISH_GRAFFITI_NAME}_backup.json"
echo "Account used now: $(ironfish wallet:which)"
echo "Account balance: $(ironfish wallet:balance)"
echo ""
echo "############# Ironfish commands #############"
echo "Get coins from faucet: ironfish faucet"
echo "Check node health status: ironfish status | grep Blockchain | awk '{print $NF}'"
echo "Check current ironfish systemd service status: systemctl status ironfishd.service"
echo "Check last ironfish systemd service logs: journalctl -n500 -efu ironfishd.service"
