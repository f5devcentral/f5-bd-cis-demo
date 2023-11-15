#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do
	use-cluster.sh $CLUSTER_ALIAS

	oc delete ns mc-twotier-shard-mc

done


