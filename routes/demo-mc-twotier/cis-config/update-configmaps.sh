#!/bin/bash
#

for CLUSTER_ALIAS in ocp1 ocp2; do
	use-cluster.sh $CLUSTER_ALIAS
	oc apply -f global-cm.bigip1.yaml
	oc apply -f global-cm.bigip2.yaml
done


