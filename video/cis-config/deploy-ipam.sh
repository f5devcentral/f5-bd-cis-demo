#!/bin/bash

source deploy.cfg

for CLUSTER_ALIAS in ocp1 ocp2; do

        echo ">>> Cluster ${CLUSTER_ALIAS}"

        oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
        oc login -u ${OCP_USER} -p ${OCP_PASS}

	oc apply -f ipam-pv.yaml
	oc apply -f ipam-pvc.yaml

	helm install -n cis-mc-twotier -f values.yaml f5-ipam-controller f5-ipam-controller-0.0.4.tgz 
done

