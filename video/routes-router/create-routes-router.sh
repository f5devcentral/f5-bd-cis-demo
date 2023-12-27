#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do
	use-cluster.sh $CLUSTER_ALIAS

	oc create ns applications

	for route in route-*.${CLUSTER_ALIAS}.yaml ; do

		echo ">>> Applying $route in cluster $CLUSTER_ALIAS" 
		oc apply -f $route	
	done
done


