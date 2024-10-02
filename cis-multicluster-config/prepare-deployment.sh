#!/bin/bash

source config

for i in "${!CLUSTERS_ALIAS[@]}" ; do

	CLUSTER_ALIAS=${CLUSTERS_ALIAS[$i]}

        echo ">>> Cluster ${CLUSTER_ALIAS}"

	export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
	kubectl config use-context $(eval echo -n $KUBECONTEXTS)
        eval $KUBELOGINS

	kubectl create ns ${CIS_NS} --dry-run=client -o yaml | kubectl apply -f -

	if [ $i -lt 2 ]; then # The clusters where CIS is installed

		kubectl label ns ${CIS_NS} f5bigipctlr="true" --overwrite
		./create-auth-config.sh ${CIS_NS} kubeconfig.${CLUSTER_ALIAS}.yaml cis-install
	else
		./create-auth-config.sh ${CIS_NS} kubeconfig.${CLUSTER_ALIAS}.yaml no-cis-install
	fi
done

