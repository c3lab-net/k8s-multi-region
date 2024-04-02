## Setup instructions

This folder holds the setup script for kubernetes + kube-ovn + kubevirt.

First set up (passwordless) SSH to a list of nodes and update [nodes.txt](./nodes.txt).
Then run the [automated bootstrap script](./bootstrap.sh) to complete the setup/installation.

Required tools:
- bash
- ssh
- parallel-ssh
