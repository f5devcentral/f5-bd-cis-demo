#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2; do

        oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
        oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions
        echo ">>> Cluster ${CLUSTER_ALIAS}"

        helm -n cis-mc-twotier uninstall f5-ipam-controller

	oc delete -f ipam-pvc.yaml
        oc delete -f ipam-pv.yaml

done


