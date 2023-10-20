#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do
	use-cluster.sh $CLUSTER_ALIAS

	oc create ns mc-twotier-shard-mc
	oc label ns mc-twotier-shard-mc router=mc-shard

	for route in route-mc-shard.${CLUSTER_ALIAS}-?.yaml ; do

		echo ">>> $route"
		oc apply -f $route	
	done
done


