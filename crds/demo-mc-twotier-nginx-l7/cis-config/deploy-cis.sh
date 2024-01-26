#!/bin/bash

source deploy.cfg

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do

        echo ">>> Cluster ${CLUSTER_ALIAS}"

	oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
	oc login -u ${OCP_USER} -p ${OCP_PASS}

	oc create ns cis-mc-twotier

        if [ $CLUSTER_ALIAS = $PRIMARY ] || [ $CLUSTER_ALIAS = $SECONDARY ]; then
                oc apply -f cis-health-bigip1.yaml
                oc apply -f cis-health-bigip2.yaml

       	 	# kubectl create -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml
        	CIS_VERSION=v2.15.0
        	kubectl create -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/${CIS_VERSION}/docs/config_examples/customResourceDefinitions/customresourcedefinitions.yml

        fi

        kubectl apply -f bigip-ctlr-clusterrole.yaml
        oc adm policy add-cluster-role-to-user cluster-admin -z bigip-ctlr -n cis-mc-twotier

	./create-kubeconfig.sh ${CLUSTER_ALIAS}

done

for CLUSTER_ALIAS in ocp1 ocp2; do

        echo ">>> Cluster ${CLUSTER_ALIAS}"

        oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
        oc login -u ${OCP_USER} -p ${OCP_PASS} 

	for CLUSTER_ALIAS_INNER_LOOP in ocp1 ocp2 ocp3; do
		kubectl create secret generic -n cis-mc-twotier kubeconfig.$CLUSTER_ALIAS_INNER_LOOP --from-file=kubeconfig=kubeconfig.$CLUSTER_ALIAS_INNER_LOOP
	done

	oc apply -f global-cm.bigip1.yaml
	oc apply -f global-cm.bigip2.yaml

	oc create secret generic bigip-login --namespace cis-mc-twotier --from-literal=username=${BIGIP_USER} --from-literal=password=${BIGIP_PASS}

	for BIGIP in 1 2; do

		oc apply -f f5-bigip${BIGIP}-ctlr-deployment.${POOLMEMBER_TYPE}.${CLUSTER_ALIAS}.yaml 
	done

done

