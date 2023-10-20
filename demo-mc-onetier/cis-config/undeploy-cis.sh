#!/bin/bash

unset KUBECONFIG

POOLMEMBER_TYPE=clusterip
PRIMARY=ocp1

for CLUSTER_ALIAS in ocp1 ocp2; do

	oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
	oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions

	echo ">>> Cluster ${CLUSTER_ALIAS}"

	oc delete ns cis-mc-onetier

#       if [ $CLUSTER_ALIAS = "ocp1" ] || [ $CLUSTER_ALIAS = "ocp2" ]; then
#		kubectl delete -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml
#       fi

done

