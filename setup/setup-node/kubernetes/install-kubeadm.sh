#!/bin/bash

set -e

# Kubernetes with kubeadm
## Source: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

echo "Installing kubernetes via kubeadm ..."

## Installing kubeadm, kubelet and kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key -o /etc/apt/keyrings/kubernetes-apt-keyring.asc

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
# sudo apt-mark hold kubelet kubeadm kubectl

echo "Performing post-install steps ..."

## configure cgroup driver
cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# Remove cri from disabled plugins
sudo sed -i 's/disabled_plugins = \["cri"\]/disabled_plugins = []/g' /etc/containerd/config.toml
sudo systemctl restart containerd

sudo systemctl restart docker
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Done"

# Add-ons

# ## Metrics-server
# LOCAL_REGISTRY_ROOT=$(realpath registry/public-registry-modified)
# mkdir -p $LOCAL_REGISTRY_ROOT && cd $LOCAL_REGISTRY_ROOT
# wget -x https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
# # Need to add argument "--kubelet-insecure-tls" to metrics-server
# kubectl apply -f github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
# cd -
