#!/bin/bash

unset KUBECONFIG

POOLMEMBER_TYPE=clusterip
PRIMARY=ocp1

for CLUSTER_ALIAS in ocp1 ocp2; do

	oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
	oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions
	echo ">>> Cluster ${CLUSTER_ALIAS}"

	oc create ns cis-mc-onetier

	# It should be possible to address the POD directly with the DNS and avoid having to create a NodePort

        if [ $CLUSTER_ALIAS = $PRIMARY ]; then
                oc apply -f cis-health-bigip1.yaml
                oc apply -f cis-health-bigip2.yaml
        fi

        kubectl apply -f bigip-ctlr-clusterrole.yaml
        oc adm policy add-cluster-role-to-user cluster-admin -z bigip-ctlr -n cis-mc-onetier

	./create-kubeconfig.sh ${CLUSTER_ALIAS}

done

# I have removed the CIS HA because right now it is incompatible with --namespace-label, see https://github.com/F5Networks/k8s-bigip-ctlr/issues/3100#issuecomment-1764149105

for CLUSTER_ALIAS in ocp1 ocp2; do

        oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
        oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions
        echo ">>> Cluster ${CLUSTER_ALIAS}"

        # https://github.com/F5Networks/k8s-bigip-ctlr/blob/master/docs/config_examples/customResourceDefinitions/crd_update.md
        # CIS_VERSION=v2.12.0
        # kubectl create -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/${CIS_VERSION}/docs/config_examples/customResourceDefinitions/customresourcedefinitions.yml
	kubectl apply -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml

	for CLUSTER_ALIAS_INNER_LOOP in ocp1 ocp2; do
		kubectl create secret generic -n cis-mc-onetier kubeconfig.$CLUSTER_ALIAS_INNER_LOOP --from-file=kubeconfig=kubeconfig.$CLUSTER_ALIAS_INNER_LOOP
	done

        oc apply -n cis-mc-onetier -f policy-default.yaml
        oc label ns cis-mc-onetier environment=test

	# oc apply -f global-cm.yaml
	oc apply -f global-cm.bigip1.yaml
	oc apply -f global-cm.bigip2.yaml

	oc create secret generic bigip-login --namespace cis-mc-onetier --from-literal=username=admin --from-literal=password=OpenShiftMC

	for BIGIP in 1 2; do

		oc apply -f f5-bigip${BIGIP}-ctlr-deployment.${POOLMEMBER_TYPE}.${CLUSTER_ALIAS}.yaml 
	done

done

