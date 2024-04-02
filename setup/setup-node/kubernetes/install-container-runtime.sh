#!/bin/bash

set -e

# install docker
## Source: https://docs.docker.com/engine/install/ubuntu/

echo "Installing docker ..."

## cleanup
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc || true

## Install using the repository

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings/
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

## uninstall docker

: '
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
#'

## post-install steps

echo "Performing post-install steps ..."

### enable docker without sudo
# sudo groupadd docker
sudo usermod -aG docker $USER
# For interactive shell only
# newgrp docker
# docker run hello-world

### configure docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# end install docker

# Networking setup
## Source: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

echo "Setting up networking ..."

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
