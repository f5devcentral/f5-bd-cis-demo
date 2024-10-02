#!/bin/bash

source config

### Templates

rm -f global-cm.${CLUSTERS_ALIAS[0]}.yaml
rm -f global-cm.${CLUSTERS_ALIAS[1]}.yaml

rm -f f5bigipctlr.${CLUSTERS_ALIAS[0]}.yaml
rm -f f5bigipctlr.${CLUSTERS_ALIAS[1]}.yaml

rm -f f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[0]}.yaml
rm -f f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[1]}.yaml

### Authentication configuration

for i in "${!CLUSTERS_ALIAS[@]}" ; do

	CLUSTER_ALIAS=${CLUSTERS_ALIAS[$i]}

        echo ">>> Cluster ${CLUSTER_ALIAS}"

	export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
	kubectl config use-context $(eval echo -n $KUBECONTEXTS)
        eval $KUBELOGINS

	kubectl delete sa f5-bigip-ctlr-serviceaccount -n ${CIS_NS}
	kubectl delete clusterrole bigip-ctlr-clusterrole
	kubectl delete clusterrolebinding bigip-ctlr-clusterrole-binding

	# Skip clusters where there are no kubeconfigs. These are only where CIS instances are deployed
	if [ $i -gt 1 ]; then
		continue
	fi

	for j in "${!CLUSTERS_ALIAS[@]}" ; do

		CLUSTER_KUBECONFIG=${CLUSTERS_ALIAS[$j]}
		kubectl delete secret -n ${CIS_NS} kubeconfig.${CLUSTER_KUBECONFIG}
	done

done

