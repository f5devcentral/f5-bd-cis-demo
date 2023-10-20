#!/bin/bash

if [ $# -ne 1 ]; then
	echo Need to specify cluster alias
	echo
	echo Example: $0 ocp2
	echo
	exit 1
fi

CLUSTER_ALIAS=$1

oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
# oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions

