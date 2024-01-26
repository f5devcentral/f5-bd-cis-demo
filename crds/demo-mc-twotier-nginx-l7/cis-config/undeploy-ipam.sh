#!/bin/bash

source deploy.cfg

for CLUSTER_ALIAS in ocp1 ocp2; do

        echo ">>> Cluster ${CLUSTER_ALIAS}"

        oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
        oc login -u ${OCP_USER} -p ${OCP_PASS}


        helm -n cis-mc-twotier uninstall f5-ipam-controller

	oc delete -f ipam-pvc.yaml
        oc delete -f ipam-pv.yaml

done


