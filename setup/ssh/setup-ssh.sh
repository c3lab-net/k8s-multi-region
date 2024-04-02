#!/bin/bash

cd "$(dirname "$0")"

set -e

# Define the nodes
readarray -t NODES < ../nodes.txt

# Generate the SSH config file
nodes_list=$(echo "${NODES[*]}")
sed 's/VAR_HOSTS/'"$nodes_list"'/g' ./config.template > ./config

# Generate SSH key pair if not already generated
if [ ! -f ./id_k8s_internal.pub ]; then
    ssh-keygen -t rsa -b 4096 -C "k8s internal" -N "" -f ./id_k8s_internal
fi

# Iterate through each node
for node in "${NODES[@]}"; do
    echo "Setting up passwordless SSH for $node..."

    # Copy public key to remote node
    ssh-copy-id -f -i ./id_k8s_internal.pub "$node"

    # Copy the private key to remote node
    scp ./id_k8s_internal "$node":~/.ssh/id_rsa

    # Copy ssh config to remote node
    scp ./config "$node":~/.ssh/config

    # Allow PSSH_NODENUM environment variables
    ssh "$node" "echo 'AcceptEnv PSSH_NODENUM PSSH_HOST' | sudo tee -a /etc/ssh/sshd_config > /dev/null && sudo systemctl restart sshd"

    echo "Passwordless SSH setup completed for $node"
done

echo "Passwordless SSH setup completed for all nodes."
