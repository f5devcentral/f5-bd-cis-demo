#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do

        use-cluster.sh $CLUSTER_ALIAS

	oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.mc-shard.json --type=merge

	oc apply -f router-shard-secret.yaml
	oc apply -f router-mc-shard.yaml

done

