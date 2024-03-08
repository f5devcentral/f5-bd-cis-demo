#!/bin/bash

CLUSTER_ALIAS=$1

use-cluster.sh $CLUSTER_ALIAS

oc create ns mc-twotier

for route in deployment-route-?.${CLUSTER_ALIAS}.yaml ; do

	echo ">>> $route"
	oc apply -f $route	
done


