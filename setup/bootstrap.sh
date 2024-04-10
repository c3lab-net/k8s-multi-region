#!/bin/bash

cd "$(dirname "$0")"
NODES_FILE="./nodes.txt"

set -e
# set -x

echo "This script will set up a Kubernetes cluster using kubeadm, and configure kube-oven and kubevirt plugins."

# Define the nodes
readarray -t NODES < "$NODES_FILE"

# ./ssh/setup-ssh.sh

REMOTE_ROOT_DIR="/tmp/setup"

echo "Copying setup directory to all nodes..."
parallel-ssh -i -h "$NODES_FILE" "rm -rf $REMOTE_ROOT_DIR" || { echo "Error removing remote setup directory"; exit 1; }
parallel-scp -h "$NODES_FILE" -r ./setup-node "$REMOTE_ROOT_DIR" || { echo "Error copying setup directory"; exit 1; }

# Run bootstrap.sh on each node in parallel
echo "Bootstraping nodes in parallel..."

node_list=$(echo "${NODES[*]}")
node_main="${NODES[0]}"
node_others="$(echo "${NODES[@]:1}")"

run_on_nodes()
{
    local nodes="$(echo "$1" | sed "s/,/ /g")"
    shift
    parallel-ssh -t 300 -i -H "$nodes" "$@" || { echo "Error running bootstrap.sh"; exit 1; }
}

echo "Installing kubernetes on all nodes..."
run_on_nodes "$node_list" "cd $REMOTE_ROOT_DIR && bash ./kubernetes/setup-k8s.sh"

echo "Initializing kubernetes cluster..."
ssh "$node_main" "cd $REMOTE_ROOT_DIR && bash ./kubernetes/initialize-cluster.sh"

echo "Distributing kube config to other nodes..."
scp "$node_main":.kube/config ./kube_config
parallel-scp -H "$node_others" ./kube_config '/tmp/kube_config'
parallel-ssh -i -H "$node_others" 'mkdir -p $HOME/.kube && mv /tmp/kube_config $HOME/.kube/config'

echo "Joining other nodes to the cluster..."
kubeadm_join_command=$(ssh "$node_main" "kubeadm token create --print-join-command")
kubeadm_join_args=$(echo "$kubeadm_join_command" | sed 's/^kubeadm join //g')
run_on_nodes "$node_others" "sudo kubeadm join $kubeadm_join_args"

echo "Installing kube-ovn ..."
ssh "$node_main" "cd $REMOTE_ROOT_DIR && bash ./kube-ovn/setup-kubeovn.sh"

echo "Installing kubevirt ..."
ssh "$node_main" "cd $REMOTE_ROOT_DIR && bash ./kubevirt/install-kubevirt.sh"

echo "Installing virtctl on all nodes..."
run_on_nodes "$node_list" "cd $REMOTE_ROOT_DIR && bash ./kubevirt/install-virtctl.sh"

run_on_nodes "$node_list" rm -rf "$REMOTE_ROOT_DIR"
