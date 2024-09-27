#!/bin/bash

CLUSTER_ALIAS=$1
# If $2 value is "delete-crds" the CRDs will be deleted
DELETE_CRDS=$2

if [ -z $CLUSTER_ALIAS ]; then

	echo "Needs to specify cluster alias as argument, ie: $0 cluster"
	exit 1
fi

source config

export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
kubectl config use-context $(eval echo -n $KUBECONTEXTS)
eval $KUBELOGINS

if [ $INSTALL_TYPE = "operator" ]; then
	kubectl delete -f operator/f5bigipctlr.${CLUSTER_ALIAS}.yaml
else
	kubectl delete -f deployment/f5-bigip-ctlr-deployment.${CLUSTER_ALIAS}.yaml -n ${CIS_NS}
fi

# The HA-group health Service is still in the namespace after removing the operand
kubectl delete ns ${CIS_NS}

# This will delete the manifests created by the users with these CRDs
if [ "x$DELETE_CRDS" = "xdelete-crds" ]; then
	kubectl delete -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/${CIS_VERSION}/docs/config_examples/customResourceDefinitions/customresourcedefinitions.yml
fi

