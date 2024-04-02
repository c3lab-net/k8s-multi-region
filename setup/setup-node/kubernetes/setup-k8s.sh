#!/bin/zsh

cd "$(dirname "$0")"

set -e

bash ./install-container-runtime.sh
bash ./install-kubeadm.sh
