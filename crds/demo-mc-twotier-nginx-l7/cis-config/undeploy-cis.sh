#!/bin/bash

source deploy.cfg

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do

	oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
	oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions
	echo ">>> Cluster ${CLUSTER_ALIAS}"

	oc delete ns cis-mc-twotier

        if [ $CLUSTER_ALIAS = $PRIMARY ] || [ $CLUSTER_ALIAS = $SECONDARY ]; then

                kubectl delete -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml

        fi

done

