#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do

        use-cluster.sh $CLUSTER_ALIAS

	oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.orig.json --type=json

	oc delete -f router-mc-shard.yaml
done

