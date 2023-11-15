#!/bin/bash

for CLUSTER_ALIAS in ocp1 ocp2 ocp3; do

	use-cluster.sh $CLUSTER_ALIAS

        if [ $CLUSTER_ALIAS = "ocp1" ] || [ $CLUSTER_ALIAS = "ocp2" ]; then
		for route in route*.yaml ; do
			echo ">>> $route"
			oc apply -f $route
		done
	fi

	for service in service.${CLUSTER_ALIAS}-?.yaml ; do

		echo ">>> $service"
		oc apply -f $service
	done
done


