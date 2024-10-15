#!/bin/bash

CLUSTER_ALIAS=$1

if [ -z $CLUSTER_ALIAS ]; then

	echo "Needs to specify cluster alias as argument, ie: $0 cluster"
	exit 1
fi

source config

export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
kubectl config use-context $(eval echo -n $KUBECONTEXTS)
eval $KUBELOGINS

if [ $INSTALL_TYPE = "operator" ]; then
	source templates/f5bigipctlr.cluster0.tmpl > f5bigipctlr.${CLUSTERS_ALIAS[0]}.yaml
        source templates/f5bigipctlr.cluster1.tmpl > f5bigipctlr.${CLUSTERS_ALIAS[1]}.yaml
else
	source templates/f5-bigip-ctlr-deployment.cluster0.yaml > f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[0]}.yaml
        source templates/f5-bigip-ctlr-deployment.cluster1.yaml > f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[1]}.yaml
fi

if [ $INSTALL_TYPE = "operator" ]; then
	kubectl apply -f f5bigipctlr.${CLUSTER_ALIAS}.yaml
else
	kubectl apply -f f5-bigip-ctlr-deployment.${CLUSTER_ALIAS}.yaml -n ${CIS_NS}
fi
