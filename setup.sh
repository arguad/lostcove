#!/bin/bash


apt upgrade -y

apt install git openssl libssl-dev curl python3-testresources docker-compose nodejs npm htop expect -y

ram_gb=`free -g | grep Mem: | awk '{ print $2 }'`
coldkey_pw=`openssl rand -base64 14`
wallet_name=bittensor-wallet-`hostname`

mkdir /root/credentials
chmod 700 /root/credentials
printf '3\r' | update-alternatives --config editor

#ulimit -n 1000000

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opentensor/bittensor/master/scripts/install.sh)"
curl -fsSL https://raw.githubusercontent.com/opentensor/bittensor/master/scripts/install.sh -o /opt/bittensor_install.sh
chmod 755 /opt/bittensor_install.sh
sed -i 's/wait_for_user()/inactive()/g' bittensor_install.sh
sed -i 's/wait_for_user/#wait_for_user/g' bittensor_install.sh
/bin/bash -c /opt/bittensor_install.sh

git clone https://github.com/opentensor/subtensor.git ~/.bittensor/subtensor

cd ~/.bittensor/subtensor

sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1G count=$ram_gb
sudo chmod 0600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

#/root/.bittensor/subtensor/docker-compose.yml

cat > /root/.bittensor/subtensor/docker-compose.yml <<EOF
version: "3.2"

services:
  node-subtensor:
    container_name: node-subtensor
    image: opentensorfdn/subtensor:latest
    ports:
      - "9944:9944"
      - "30333:30333"
      - "9933:9933"
    environment:
      - CARGO_HOME=/var/www/node-subtensor/.cargo
    command: bash -c "/usr/local/bin/node-subtensor --base-path /root/.local/share/node-subtensor/ --chain /subtensor/specs/nakamotoSpecRaw.json --rpc-external --ws-external --rpc-cors all --no-mdns --rpc-methods=Unsafe --ws-max-connections 1000 --in-peers 500 --out-peers 500"
EOF


docker-compose up -d
npm install pm2 -g

/opt/coldkey.exp $wallet_name $coldkey_pw

for i in 1 2 3 4; do
  /opt/hotkey.exp $wallet_name hotkey$i-`hostname`
done


