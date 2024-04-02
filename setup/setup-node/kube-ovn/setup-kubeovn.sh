#!/bin/bash

cd "$(dirname "$0")"

# wget https://raw.githubusercontent.com/kubeovn/kube-ovn/release-1.12/dist/images/install.sh -O install-kubeovn.sh
bash install-kubeovn.sh
