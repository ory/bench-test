#!/usr/bin/env bash

set -euxo pipefail

bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /home/azureuser/.gvm/scripts/gvm
sudo apt-get update
sudo apt-get install make gcc bison binutils git postgresql jq -y
gvm install go1.20 -B --default
gvm use go1.20 --default

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install v16
nvm use v16  --default

git clone https://github.com/ory/hydra.git $HOME/hydra
cd $HOME/hydra
git fetch origin
git checkout aeneas-repro
go install .

git clone https://github.com/ory/hydra-login-consent-node.git $HOME/hydra-login-consent-node
cd $HOME/hydra-login-consent-node/
git checkout auto-accept-perf
npm i
export HYDRA_ADMIN_URL=http://127.0.0.1:4445

git clone https://github.com/aeneasr/hey.git $HOME/hey
cd $HOME/hey
git checkout cookie
go install .

# Docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER
