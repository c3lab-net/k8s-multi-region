#!/bin/bash

# Source: https://kubevirt.io/user-guide/operations/installation/#installing-kubevirt-on-kubernetes

set -e

echo "Installing KubeVirt on Kubernetes..."

# Point at latest release
export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
# Deploy the KubeVirt operator
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
# Create the KubeVirt CR (instance deployment request) which triggers the actual installation
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
# wait until all KubeVirt components are up
echo "Waiting for KubeVirt components to be up..."
kubectl -n kubevirt wait kv kubevirt --for condition=Available --timeout=120s
echo "Done"
