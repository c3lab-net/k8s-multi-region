#!/bin/bash

cd "$(dirname "$0")"

set -e

echo "Initializing Kubernetes cluster..."
sudo kubeadm init

echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
