#!/bin/bash

if [ -v $CLUSTER_LIST ]; then

	echo Environment variable CLUSTER_LIST is undefined or empty.
	echo
	echo It is need to specify a space separated list of clusters in CLUSTER_LIST environment variable.
	echo
	echo 'Example: export CLUSTER_LIST="ocp1 ocp2"'
	echo

	exit 1
fi

if [ $# -lt 1 ]; then
	echo Need to specify a command to run
	echo
	echo "Example: $0 <command>"
	echo
	exit 1
fi


INIT_CONTEXT=$(oc config current-context)

unset KUBECONFIG

for CLUSTER_ALIAS in $CLUSTER_LIST; do

	oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
	# oc login -u f5admin -p f5admin # the f5admin user has cluster-admin permissions

	$@

done

if [ -n ${INIT_CONTEXT} ]; then
	echo "Switching back to initial context ${INIT_CONTEXT}"
	oc config use-context ${INIT_CONTEXT}
fi

